mapModule = angular.module "geocms.map", []

mapModule.service "mapService", [() ->
  
  mapService = {}
  
  mapService.container = null
  mapService.layers = []
  mapService.crs = null

  mapService.createMap = (id, lat, lng, zoom) ->
    # options = 
    #   crs: @crs
    options = {}
    @container = new L.Map(id, options).setView([lat, lng], zoom)
    
  mapService.addBaseLayer = () ->
    # L.tileLayer.wms("http://osm.geobretagne.fr/gwc01/service/wms", {
    #   layers: "osm:google",
    #   format: 'image/png',
    #   transparent: true,
    #   continuousWorld: true,
    #   unloadInvisibleTiles: false,
    #   attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
    #     '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
    #     'Imagery © <a href="http://geobretagne.fr/accueil/">GeoBretagne</a>'
    # }).addTo(@container)
    mapboxTiles = L.tileLayer('https://{s}.tiles.mapbox.com/v3/impeyal.map-el9s7flv/{z}/{x}/{y}.png', {
        attribution: '<a href="http://www.mapbox.com/about/maps/" target="_blank">Terms &amp; Feedback</a>'
    })
    mapboxTiles.addTo(@container)
  mapService.initLayers = () ->
    # console.log(@layers)
    _.each @layers, (cl) ->
      # console.log layer
      mapService.addLayer(cl)

  mapService.addLayer = (cl) ->
    cl.layer._tilelayer = L.tileLayer.wms cl.layer.data_source_wms,
      layers: cl.layer.name,
      format: 'image/png',
      transparent: true,
      version: cl.layer.data_source_wms_version,
      styles: cl.layer.default_style || '',
      continuousWorld: true,
      tiled: cl.layer.tiled,
      maxZoom: 24,
      minZoom: 3
      opacity: (cl.opacity / 100)
    cl.layer._tilelayer.addTo(@container)

  mapService.defineProj = (crs) ->
    scale = (zoom) ->
      return 1 / (4891.96875 / Math.pow(2, zoom))

    bbox = [-357823.236499999999, 6037008.69390000030,
            894521.034699999960, 7289352.96509999968]
    transformation = new L.Transformation(1, -bbox[0], -1, bbox[1])
    @crs = new L.Proj.CRS('EPSG:2154',
                '+proj=lcc +lat_1=49 +lat_2=44 +lat_0=46.5 +lon_0=3 +x_0=700000 +y_0=6600000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs',
                transformation)

    @crs.scale = scale

  mapService
]
