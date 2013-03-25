###
Copyright (c) 2013, Markus Kohlhase <mail@markus-kohlhase.de>
###

PROJECTION_4326 = new OpenLayers.Projection "EPSG:4326"
PROJECTION_MERC = new OpenLayers.Projection "EPSG:900913"

ACTIVE_DP_ICON   =
  externalGraphic:  'dp_active_64.png'
  graphicHeight:    64
  graphicWidth:     64
  graphicYOffset:   -64
  graphicXOffset:   -24

INACTIVE_DP_ICON =
  externalGraphic:  'dp_inactive_64.png'
  graphicHeight:    64
  graphicWidth:     64
  graphicYOffset:   -64
  graphicXOffset:   -24

FARM_ICON =
  externalGraphic:  'farm.png'
  graphicHeight:    64
  graphicWidth:     64
  graphicYOffset:   -24
  graphicXOffset:   -27

DEFAULT_STYLE =
  pointRadius: 6
  fillColor: 'green'

SELECT_STYLE =
  pointRadius: 8
  fillColor: 'red'

STYLE_MAP = new OpenLayers.StyleMap
  default: DEFAULT_STYLE
  select:  SELECT_STYLE

map             = null
dpLayer         = null
memberLayer     = null
farmLayer       = null
dpSelectControl = null

getTransformedPoint = (p) ->
  dPoint = new OpenLayers.Geometry.Point(p.lon, p.lat)
    .transform(PROJECTION_4326, PROJECTION_MERC)

onFeatureSelect = (ev) ->
  f     = ev.feature
  attrs = f.attributes
  desc  = "<h2>#{attrs.name}</h2>"
  desc += "<p>"
  if attrs.address?
    desc += "#{attrs.address}<br/>"
  if attrs.zip and attrs.city?
    desc += "#{attrs.zip} #{attrs.city}"
  desc += "</p>"
  if attrs.note?
    desc += "<p>#{attrs.note}</p>"
  popup = new OpenLayers.Popup.FramedCloud "featurePopup"
    , f.geometry.getBounds().getCenterLonLat()
    , new OpenLayers.Size(100, 100)
    , desc
    , null
    , true
    , onPopupClose
  f.popup = popup
  popup.feature = f
  map.addPopup popup

onFeatureUnselect = (ev) ->
  f = ev.feature
  if f.popup
    map.removePopup f.popup
    f.popup.destroy()
    f.popup = null

onPopupClose = (evt) -> dpSelectControl.unselect @feature

addDPPoint = (p) ->
  if p.lon and p.lat
    icon = switch p.state
      when 'active'   then ACTIVE_DP_ICON
      when 'inactive' then INACTIVE_DP_ICON
      else INACTIVE_DP_ICON
    dpFeature = new OpenLayers.Feature.Vector getTransformedPoint(p), p, icon
    dpLayer.addFeatures dpFeature

addMemberPoint = (m) ->
  memberLayer.addFeatures new OpenLayers.Feature.Vector getTransformedPoint(m), m

addFarmPoint = (m) ->
  farmLayer.addFeatures new OpenLayers.Feature.Vector getTransformedPoint(m), m, FARM_ICON

onError = -> console.error "could not load data"

init = ->

  map = new OpenLayers.Map "map",
    controls : [
      new OpenLayers.Control.PanZoomBar()
      new OpenLayers.Control.Navigation()
      new OpenLayers.Control.LayerSwitcher()
      new OpenLayers.Control.MousePosition()
      new OpenLayers.Control.Attribution()
      new OpenLayers.Control.OverviewMap() ]
    maxExtent : new OpenLayers.Bounds -20037508.34, -20037508.34, 20037508.34, 20037508.34
    numZoomLevels : 18,
    maxResolution : 156543,
    units : 'm',
    projection : PROJECTION_MERC,
    displayProjection : PROJECTION_4326

  osmLayer = new OpenLayers.Layer.OSM "Open Street Map"
  map.addLayer osmLayer

  dpLayer = new OpenLayers.Layer.Vector "Verteilerpunkte"
  map.addLayer dpLayer

  farmLayer = new OpenLayers.Layer.Vector "SoLaWiS Hof"
  map.addLayer farmLayer

  memberLayer = new OpenLayers.Layer.Vector "Mitglieder", styleMap: STYLE_MAP
  map.addLayer memberLayer

  $.getJSON('data.json')
    .fail(onError)
    .done (data) ->
      for p in data
        switch p.type
          when "member" then addMemberPoint p
          when "farm"   then addFarmPoint p
          else addDPPoint p

  dpSelectControl = new OpenLayers.Control.SelectFeature dpLayer
  map.addControl dpSelectControl
  dpSelectControl.activate()

  dpLayer.events.on
    featureselected   : onFeatureSelect
    featureunselected : onFeatureUnselect

  center = new OpenLayers.LonLat 9.1772, 48.7823
  centerAsMerc = center.transform PROJECTION_4326, PROJECTION_MERC
  map.setCenter centerAsMerc, 8
  map.zoomTo 12

$ -> init()
