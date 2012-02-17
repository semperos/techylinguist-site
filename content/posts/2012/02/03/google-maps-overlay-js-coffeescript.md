## Google Maps Custom Overlay in JavaScript and CoffeeScript ##

My intention was not to do the same work twice. However, with my (1) ignorance around prototype-based inheritance and (2) Google's Maps API, I started by following a Google tutorial for creating a custom Overlay on a Google map using JavaScript and then rewrote the same JavaScript in CoffeeScript.

Here's the JavaScript:

~~~~
#!javascript
var Overlays = {};
(function() {
    ImageOverlay.prototype = new google.maps.OverlayView();
    var overlay;
    this.overlay = null;
    
    this.initialize = function(existing_map) {
        var myLatLng = new google.maps.LatLng(62.323907, -150.109291);
        var myOptions = {
            zoom: 11,
            center: myLatLng,
            mapTypeId: google.maps.MapTypeId.SATELLITE
        };

        var swBound = new google.maps.LatLng(62.281819, -150.287132);
        var neBound = new google.maps.LatLng(62.400471, -150.005608);
        var bounds = new google.maps.LatLngBounds(swBound, neBound);

        // Photograph courtesy of the U.S. Geological Survey
        var srcImage = 'http://vigilantcitizen.com/wp-content/uploads/2009/12/pinocchio2.jpg';
        this.overlay = new ImageOverlay(bounds, srcImage, existing_map);
        console.log(this.overlay);
    }

    function ImageOverlay(bounds, image, map) {

        // Now initialize all properties.
        this.bounds_ = bounds;
        this.image_ = image;
        this.map_ = map;

        // We define a property to hold the image's
        // div. We'll actually create this div
        // upon receipt of the add() method so we'll
        // leave it null for now.
        this.div_ = null;

        // Explicitly call setMap() on this overlay
        this.setMap(map);
    }

    ImageOverlay.prototype.onAdd = function() {

        // Note: an overlay's receipt of onAdd() indicates that
        // the map's panes are now available for attaching
        // the overlay to the map via the DOM.

        // Create the DIV and set some basic attributes.
        var div = document.createElement('DIV');
        div.style.border = "none";
        div.style.borderWidth = "0px";
        div.style.position = "absolute";

        // Create an IMG element and attach it to the DIV.
        var img = document.createElement("img");
        img.src = this.image_;
        img.style.width = "100%";
        img.style.height = "100%";
        div.appendChild(img);

        // Set the overlay's div_ property to this DIV
        this.div_ = div;

        // We add an overlay to a map via one of the map's panes.
        // We'll add this overlay to the overlayImage pane.
        var panes = this.getPanes();
        panes.overlayLayer.appendChild(div);
    }

    ImageOverlay.prototype.draw = function() {

        // Size and position the overlay. We use a southwest and northeast
        // position of the overlay to peg it to the correct position and size.
        // We need to retrieve the projection from this overlay to do this.
        var overlayProjection = this.getProjection();

        // Retrieve the southwest and northeast coordinates of this overlay
        // in latlngs and convert them to pixels coordinates.
        // We'll use these coordinates to resize the DIV.
        var sw = overlayProjection.fromLatLngToDivPixel(this.bounds_.getSouthWest());
        var ne = overlayProjection.fromLatLngToDivPixel(this.bounds_.getNorthEast());

        // Resize the image's DIV to fit the indicated dimensions.
        var div = this.div_;
        div.style.left = sw.x + 'px';
        div.style.top = ne.y + 'px';
        div.style.width = (ne.x - sw.x) + 'px';
        div.style.height = (sw.y - ne.y) + 'px';
    }

    ImageOverlay.prototype.onRemove = function() {
        this.div_.parentNode.removeChild(this.div_);
        this.div_ = null;
    }

    // Note that the visibility property must be a string enclosed in quotes
    ImageOverlay.prototype.hide = function() {
        if (this.div_) {
            this.div_.style.visibility = "hidden";
        }
    }

    ImageOverlay.prototype.show = function() {
        if (this.div_) {
            this.div_.style.visibility = "visible";
        }
    }

    ImageOverlay.prototype.toggle = function() {
        if (this.div_) {
            if (this.div_.style.visibility == "hidden") {
                this.show();
            } else {
                this.hide();
            }
        }
    }

    ImageOverlay.prototype.toggleDOM = function() {
        if (this.getMap()) {
            this.setMap(null);
        } else {
            this.setMap(this.map_);
        }
    }

}).apply(Overlays)
~~~~

And here's the CoffeeScript:

~~~~
#!ruby
class Orion.BaseModels.Overlays
  initialize: (map) =>
    myLatLng = new google.maps.LatLng(62.323907, -150.109291)
    myOptions =
      zoom: 11
      center: myLatLng
      mapTypeId: google.maps.MapTypeId.SATELLITE

    swBound = new google.maps.LatLng(62.281819, -150.287132)
    neBound = new google.maps.LatLng(62.400471, -150.005608)
    bounds = new google.maps.LatLngBounds(swBound, neBound)

    srcImage = 'http://vigilantcitizen.com/wp-content/uploads/2009/12/pinocchio2.jpg'
    @overlay = new ImageOverlay(bounds, srcImage, map)
    console.log @overlay

class ImageOverlay extends google.maps.OverlayView
  constructor: (bounds, image, map) ->
    @bounds_ = bounds
    @img_ = image
    @map = map

    @div_ = null
    @setMap map

  onAdd: ->
    div = document.createElement 'div'
    div.style.border = 'none'
    div.style.borderWidth = '0px'
    div.style.position = 'absolute'

    img = document.createElement 'img'
    img.src = @img_
    img.style.width = '100%'
    img.style.height = '100%'
    div.appendChild img

    @div_ = div

    panes = @getPanes()
    panes.overlayLayer.appendChild(div)

  draw: ->
    overlayProjection = @getProjection()
    sw = overlayProjection.fromLatLngToDivPixel(@bounds_.getSouthWest())
    ne = overlayProjection.fromLatLngToDivPixel(@bounds_.getNorthEast())

    div = @div_
    div.style.left = sw.x + 'px'
    div.style.top = ne.y + 'px'
    div.style.width = (ne.x - sw.x) + 'px'
    div.style.height = (sw.y - ne.y) + 'px'

  onRemove: ->
    @div_.parentNode.removeChild(@div_)
    @div_ = null

  hide: ->
    if @div_
      @div_.style.visibility = 'hidden'

  show: ->
    if @div_
      @div_.style.visibility = 'visible'

  toggle: ->
    if @div_
      if @div_.style.visibility is 'hidden'
        @show()
      else
        @hide()

  toggleDOM: ->
    if @getMap()
      @setMap null
    else
      @setMap @map_
~~~~
