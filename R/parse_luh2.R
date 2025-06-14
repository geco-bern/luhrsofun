#' Parse LUH2 data
#'
#' Build land-use change (LUC) transition matrix and initial states from LUH2 v2 data (https://luh.umd.edu/data.shtml).
#'
#' @param state_file Path to states.nc ncdf file
#' @param trans_file Path to transitions.nc ncdf file
#' @param lon Longitude (degrees E)
#' @param lat Latitude (degrees N)
#' @param start Start index (minimum is 1)
#' @param n Number of years to process (-1 for all years)
#' @param simplified Reduce the number of states from 12 to 5
#'
#' @return A list containing the intial states ('states_init') and transition matrix ('luc_matrix')
#' @export
#' @importFrom utils head
#' @importFrom ncdf4 nc_open
#' @importFrom ncdf4 ncvar_get
#' @importFrom ncdf4 nc_close
parse_luh2 <- function(state_file, trans_file, lon, lat, start=1, n=-1, simplified=FALSE){

  ### Open the ncdf files

  # State[lon,lat,time]
  nc_state <- ncdf4::nc_open(state_file)
  # Trans[lon,lat,time]
  nc_trans <- ncdf4::nc_open(trans_file)

  ### Convert lon, lat into indices
  lon_idx <- which.min(abs(nc_state$dim$lon$vals - lon))
  lat_idx <- which.min(abs(nc_state$dim$lat$vals - lat))

  ### Convenience function to extract one variable from ncdf
  get_var <- function(var_name, data, lon_idx, lat_idx, start=1, n=-1) {
    ncdf4::ncvar_get(data, varid = var_name,
                     start= c(lon_idx,
                              lat_idx,
                              start
                     ),
                     count=c(1, 1, n))
  }

  state_names <- c(
    'primf',
    'primn',
    'secdf',
    'secdn',
    'urban',
    'c3ann',
    'c4ann',
    'c3per',
    'c4per',
    'c3nfx',
    'pastr',
    'range'
  )
  # Check that the file contains the expected states
  if (! isTRUE(all.equal(state_names, head(names(nc_state[['var']]), 12)))) {
    stop("Unexpected state names. Make sure you are using LUH2 v2 ncdf files.")
  }

  # Fetch the initial states
  states_init <- sapply(state_names, \(x) get_var(x, nc_state, lon_idx, lat_idx, start, 1))
  # states <- sapply(state_names, \(x) get_var(x, nc_state, lon_idx, lat_idx, start + 1, n + 1))

  # Fetch the transition names
  trans_names <- head(names(nc_trans[['var']]), 113)

  # Fetch the transitions
  trans <- sapply(trans_names, \(x) get_var(x, nc_trans, lon_idx, lat_idx, start, n))

  # Close all files
  ncdf4::nc_close(nc_state)
  ncdf4::nc_close(nc_trans)

  # Convenience variables
  zero <- 113
  zeros <- matrix(0, n, 1)

  # Merge 111 and 112 and add a column of zeros
  trans[,111] <- trans[,111]+trans[,112]
  trans <- cbind(trans[,-112], zeros)

  # Column order
  col_order <- c(
    rep(zero, 24),
    109, 10, 111, seq(28, 100, by=9),
    1, 110, 19, 112, seq(38, 101, by=9),
    seq(2, 29, by=9), zero, seq(48, 102, by=9),
    seq(3, 39, by=9), zero, seq(58, 103, by=9),
    seq(4, 49, by=9), zero, seq(68, 104, by=9),
    seq(5, 59, by=9), zero, seq(78, 105, by=9),
    seq(6, 69, by=9), zero, seq(88, 106, by=9),
    seq(7, 79, by=9), zero, seq(98, 107, by=9),
    seq(8, 89, by=9), zero, 108,
    seq(9, 99, by=9), zero
  )
  # Put the data under matrix form using the custom column order
  trans <- array(trans[,col_order], c(n, 12, 12))
  trans <- aperm(trans, c(2, 3, 1))

  if (simplified) {
    states_init <- simplify_luh2_states(states_init)
    trans <- simplify_luh2_transitions(trans)
  }

  return(list(states_init = states_init, luc_matrix = trans))
}

#' Simplify LUH2 transition matrix
#'
#' Simplify initial states parsed from LUH2 v2 data (https://luh.umd.edu/data.shtml).
#'
#' @param init_states Initial states parsed from LUH2.
#' The 12 original LUH2 states are merged into 5 simplified states.
#'
#' @return Simplified initial states tibble
simplify_luh2_states <- function(init_states) {

  res <- c(
    init_states['primf'] + init_states['primn'],
    init_states['secdf'] + init_states['secdn'],
    init_states['urban'],
    init_states['c3ann'] + init_states['c4ann'] + init_states['c3per'] + init_states['c4per'] + init_states['c3nfx'],
    init_states['pastr'] + init_states['range']
  )
  names(res) <- c('prim', 'secd', 'urban', 'cropland', 'pasture')

  return (res)
}

#' Simplify LUH2 transition matrix
#'
#' Simplify transition matrix parsed from LUH2 v2 data (https://luh.umd.edu/data.shtml).
#'
#' @param trans Transition matrix parsed from LUH2.
#' The 12 original LUH2 states are merged into 5 simplified states.
#'
#' @return Simplified transition matrix
simplify_luh2_transitions <- function(trans) {

  arr <- array(c(
    colSums(trans[1:2, 1:2,], dims=2),
    colSums(trans[1:2, 3:4,], dims=2),
    colSums(trans[1:2, 5,]),
    colSums(trans[1:2, 6:10,], dims=2),
    colSums(trans[1:2, 11:12,], dims=2),
    #
    colSums(trans[3:4, 1:2,], dims=2),
    colSums(trans[3:4, 3:4,], dims=2),
    colSums(trans[3:4, 5,]),
    colSums(trans[3:4, 6:10,], dims=2),
    colSums(trans[3:4, 11:12,], dims=2),
    #
    colSums(trans[5, 1:2,]),
    colSums(trans[5, 3:4,]),
    trans[5, 5,],
    colSums(trans[5, 6:10,]),
    colSums(trans[5, 11:12,]),
    #
    colSums(trans[6:10, 1:2,], dims=2),
    colSums(trans[6:10, 3:4,], dims=2),
    colSums(trans[6:10, 5,]),
    colSums(trans[6:10, 6:10,], dims=2),
    colSums(trans[6:10, 11:12,], dims=2),
    #
    colSums(trans[11:12, 1:2,], dims=2),
    colSums(trans[11:12, 3:4,], dims=2),
    colSums(trans[11:12, 5,]),
    colSums(trans[11:12, 6:10,], dims=2),
    colSums(trans[11:12, 11:12,], dims=2)
  ), c(length(trans[1,1,]), 5, 5)
  )
  aperm(arr, 3:1)
}
