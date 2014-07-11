geocms = angular.module( 'geocms', [
  'ui.router'
  'restangular'
  'ui.slider'
  'geocms.contexts'
  'geocms.map'
  'geocms.layer'
  'geocms.catalog'
])

geocms.config [
  "$httpProvider", 
  "$stateProvider",
  "$locationProvider",
  "$urlRouterProvider",
  ($httpProvider, $stateProvider, $locationProvider, $urlRouterProvider) ->
    $locationProvider.html5Mode(true)
]

geocms.run [ 
  "Restangular",
  "mapService"
  (Restangular, mapService) ->
    Restangular.setBaseUrl("/api/v1")
    mapService.defineProj("EPSG:2154")
]