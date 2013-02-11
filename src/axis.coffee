###
Axis (Guide)
---------
Classes related to the generation and management of axes.

Like layers, Axis class (and classes that extends Guide) takes in required
input about the data domain, scales, etc and produces abstract geometrical
objects that can later be rendered using Geometry class.
###

sf = poly.const.scaleFns

class Axis extends poly.Guide
  constructor: (params) ->
    {domain, type, guideSpec, key} = params
    # helper
    option = (item, def) => guideSpec[item] ? def
    # position
    @position = option('position', @defaultPosition)
    if @position not in @validPositions
      throw poly.error.defn "X-axis position can't be #{@position}."
    @titletext = option('title', key)
    @renderTick = option('renderTick', true)
    @renderGrid = option('renderGrid', true)
    @renderLabel = option('renderLabel', true)
    @renderLine = option('renderLine', true)
    # ticks
    @ticks = poly.tick.make domain, guideSpec, type
    @maxwidth = _.max _.map @ticks, (t) -> poly.strSize t.value
    @maxwidth = Math.max @maxwidth, 0
  calculate: (axisDim, @coord, override) =>
    if @position is "none" then return {}
    override ?= {}
    axisDim.centerx = axisDim.left + axisDim.width/2
    axisDim.centery = axisDim.top + axisDim.height/2
    axisDim.radius = Math.min(axisDim.width, axisDim.height)/2 -10

    geoms = {}
    if @renderLine
      geoms['line'] = marks: 0: @_renderline(axisDim)
    for key, tick of @ticks
      marks = {}
      if @renderTick and (override.renderTick ? true)
        marks.tick = @_makeTick(axisDim, tick)
      if @renderLabel and (override.renderLabel ? true)
        marks.text = @_makeLabel(axisDim, tick)
      if @renderGrid and (override.renderGrid ? true)
        marks.grid = @_makeGrid(axisDim, tick) # how to make this go to back?
      geoms[key] = marks: marks
    geoms
  _makeTick : (obj) ->
    if !obj then throw poly.error.impl()
    obj.type = 'path'
    obj.stroke = sf.identity 'black'
    obj
  _makeLabel: (obj) ->
    if !obj then throw poly.error.impl()
    obj.type = 'text'
    obj
  _makeGrid: (obj) ->
    if !obj then throw poly.error.impl()
    obj.stroke = '#CCC'
    obj['stroke-dasharray'] = '- '
    obj['stroke-dashoffset'] = 3
    obj

class XAxis extends Axis # assumes position = bottom
  constructor: (params) ->
    @type = 'x'
    @defaultPosition = 'bottom'
    @validPositions = ['top', 'bottom', 'none']
    super(params)
  _renderline : (axisDim) ->
    if @position is 'top'
      y = sf.identity axisDim.top
    else
      y = sf.identity axisDim.bottom
    x1 = sf.identity axisDim.left
    x2 = sf.identity axisDim.left+axisDim.width
    type: 'path'
    y: [y, y]
    x: [x1, x2]
    stroke: sf.identity 'black'
  _makeTick: (axisDim, tick) ->
    if @position is 'top'
      y1 = sf.identity(axisDim.top)
      y2 = sf.identity(axisDim.top-5)
    else
      y1 = sf.identity(axisDim.bottom)
      y2 = sf.identity(axisDim.bottom+5)
    super
      x : [tick.location, tick.location]
      y : [y1, y2]
  _makeLabel: (axisDim, tick) ->
    if @position is 'top'
      y = sf.identity(axisDim.top-15)
    else
      y = sf.identity(axisDim.bottom+15)
    super
      x : tick.location
      y : y
      text: tick.value
      'text-anchor' : 'middle'
  _makeGrid: (axisDim, tick) ->
    y1 = sf.identity(axisDim.top)
    y2 = sf.identity(axisDim.bottom)
    super
      type: 'path'
      x : [tick.location, tick.location]
      y : [y1, y2]
  getDimension: () ->
    position: @position ? 'bottom'
    height: 30
    width: 'all'

class YAxis extends Axis # assumes position = left
  constructor: (params) ->
    @type = 'y'
    @defaultPosition = 'left'
    @validPositions = ['left', 'right', 'none']
    super(params)
  _renderline : (axisDim) ->
    if @position is 'left'
      x = sf.identity axisDim.left
    else
      x = sf.identity axisDim.right
    y1 = sf.identity axisDim.top
    y2 = sf.identity axisDim.top+axisDim.height
    type: 'path'
    x: [x, x]
    y: [y1, y2]
    stroke: sf.identity 'black'
  _makeTick: (axisDim, tick) ->
    if @position is 'left'
      x1 = sf.identity(axisDim.left)
      x2 = sf.identity(axisDim.left-5)
    else
      x1 = sf.identity(axisDim.right)
      x2 = sf.identity(axisDim.right+5)
    super
      x : [x1, x2]
      y : [tick.location, tick.location]
  _makeLabel: (axisDim, tick) ->
    if @position is 'left'
      x = sf.identity(axisDim.left-7)
    else
      x = sf.identity(axisDim.right+7)
    super
      x : x
      y : tick.location
      text: tick.value
      'text-anchor' : if @position is 'left' then 'end' else 'start'
  _makeGrid: (axisDim, tick) ->
    x1 = sf.identity(axisDim.left)
    x2 = sf.identity(axisDim.right)
    super
      type: 'path'
      y : [tick.location, tick.location]
      x : [x1, x2]
  getDimension: () ->
    position: @position ? 'right'
    height: 'all'
    width: 5+@maxwidth

class RAxis extends Axis # assumes position = left
  constructor: (params) ->
    @type = 'r'
    @defaultPosition = 'left'
    @validPositions = ['left', 'right', 'none']
    super(params)
  _renderline : (axisDim) ->
    x = sf.identity axisDim.left
    y1 = sf.identity axisDim.top
    y2 = sf.identity axisDim.top+axisDim.height/2
    type: 'path'
    x: [x, x]
    y: [y1, y2]
    stroke: sf.identity 'black'
  _makeTick: (axisDim, tick) ->
    super
      x : [sf.identity(axisDim.left), sf.identity(axisDim.left-5)]
      y : [tick.location, tick.location]
  _makeLabel: (axisDim, tick) ->
    super
      x : sf.identity(axisDim.left-7)
      y : tick.location
      text: tick.value
      'text-anchor' : 'end'
  _makeGrid: (axisDim, tick) ->
    super
      type: 'circle'
      x: sf.identity axisDim.centerx
      y: sf.identity axisDim.centery
      size: sf.identity @coord.getScale('r') tick.location
      color: sf.identity('none')
      'fill-opacity': 0
      'stroke-width': 1
  getDimension: () ->
    position: 'left'
    height: 'all'
    width: 5+@maxwidth

class TAxis extends Axis # assumes position = ... um, what is it supposed to be?
  constructor: (params) ->
    @type = 't'
    @defaultPosition = 'out'
    @validPositions = ['out', 'none']
    super(params)
  _renderline : (axisDim) ->
    type: 'circle',
    x: sf.identity axisDim.centerx
    y: sf.identity axisDim.centery
    size: sf.identity axisDim.radius
    color: sf.identity('none')
    stroke: sf.identity('black')
    'stroke-width': 1
  _makeTick: (axisDim, tick) ->
    super
      x : [tick.location, tick.location]
      y : [sf.max(0), sf.max(3)]
  _makeLabel: (axisDim, tick) ->
    super
      x : tick.location
      y : sf.max(12)
      text: tick.value
      'text-anchor' : 'middle'
  _makeGrid: (axisDim, tick) ->
    x1 = sf.identity axisDim.centerx
    y1 = sf.identity axisDim.centery
    theta = @coord.getScale('t')(tick.location) - Math.PI/2
    x2 = sf.identity(axisDim.centerx + axisDim.radius * Math.cos(theta))
    y2 = sf.identity(axisDim.centery + axisDim.radius * Math.sin(theta))
    super
      type: 'path'
      y : [y1, y2]
      x : [x1, x2]
  getDimension: () -> {}

poly.guide ?= {}
poly.guide.axis = (type, params) ->
  if type == 'x'
    new XAxis(params)
  else if type == 'y'
    new YAxis(params)
  else if type == 'r'
    new RAxis(params)
  else if type == 't'
    new TAxis(params)