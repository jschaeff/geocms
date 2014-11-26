contexts = angular.module "geocms.contexts", [
  'ui.router'
  'restangular'
  'geocms.map'
  'geocms.cart'
]

contexts.config [
  "$stateProvider",
  ($stateProvider) ->
    $stateProvider
      .state 'contexts',
        url: config.prefix_uri+"/maps"
        views:
          "":
            templateUrl: config.prefix_uri+"/templates/contexts/root.html"
        abstract: true
        resolve:
          folders: ["Restangular", (Restangular) ->
            Restangular.all('folders').customGETLIST("writable")
          ]

      .state 'contexts.root',
        url: ""
        parent: "contexts"
        views:
          "sidebar@contexts":
            templateUrl: config.prefix_uri+"/templates/contexts/sidebar.html"
            controller: "ContextsController"
          "map@contexts":
            templateUrl: config.prefix_uri+"/templates/contexts/map.html"
            controller: ["context", "$state", (context, $state) ->
              if context != null && context != undefined && context != "null"
                $state.transitionTo('contexts.show', {uuid: context.uuid})
              else
                $state.transitionTo('contexts.new')
            ]
        resolve:
          context: ["Restangular", (Restangular) ->
            Restangular.all('contexts').customGET("default")
          ]

      .state 'contexts.new',
        url: '/new'
        parent: 'contexts.root'
        views:
          "map@contexts":
            templateUrl: config.prefix_uri+"/templates/contexts/map.html"
            controller: ["mapService", "folders", "$rootScope", "$scope", "Restangular", (mapService, folders, $root, $scope, Restangular) ->
              context = { center_lat: config.latitude, center_lng: config.longitude, zoom: config.zoom }
              mapService.createMap("map", context.center_lat, context.center_lng, context.zoom)
              $root.cart.context = Restangular.restangularizeElement(null, context, "contexts")
              mapService.addBaseLayer()
              $root.cart.folders = folders
              $root.cart.context.editable = true
              $scope.mapService = mapService
            ]

      .state 'contexts.show',
        url: '/{uuid}'
        parent: 'contexts.root'
        views:
          "sidebar@contexts":
            templateUrl: config.prefix_uri+"/templates/contexts/sidebar.html"
            controller: "ContextsController"
          "map@contexts":
            templateUrl: config.prefix_uri+"/templates/contexts/map.html"
            controller: ["mapService", "context", "folders", "$rootScope", "$scope", (mapService, context, folders, $root, $scope) ->
              mapService.createMap("map", context.center_lat, context.center_lng, context.zoom)
              mapService.addBaseLayer()
              $root.cart.context = context
              $root.cart.addSeveral()
              $root.cart.folders = folders
              $scope.mapService = mapService
            ]
        resolve:
          context: ["Restangular", "$stateParams", (Restangular, $stateParams) ->
            Restangular.one('contexts', $stateParams.uuid).get()
          ]

      .state 'contexts.show.share',
        url: '/share'
        parent: 'contexts.show'
        views:
          "sidebar@contexts":
            templateUrl: ""
            controller: "ContextsController"
]

contexts.controller "ContextsController", [
  "$scope"
  "$rootScope"
  "$state"
  "mapService"
  "cartService"
  "mapOptionService"

  ($scope, $root, $state, mapService, Cart, optionService) ->

    $root.cart = new Cart()

    watchers = '[cart.context.name, cart.context.description, cart.context.folder_id, cart.context.center_lng, cart.context.center_lat, cart.context.zoom]'
    $root.$watchCollection watchers, (newValues, oldValues) ->
      $root.cart.state = "unsaved" unless newValues == oldValues
    , true

    $scope.openCatalog = () ->
      if $scope.catalogOpened() then $state.go "^" else $state.go ".catalog"

    $scope.catalogOpened = () ->
      $state.current.name.indexOf('catalog') > -1

    $scope.treeOptions = {
      dropped: (event) ->
        $root.cart.recalculateLayerZIndex()
    }

    $scope.mapOptions = optionService
    $scope.mapService = mapService
]