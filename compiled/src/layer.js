(function() {
  var Layer, Line, Point, aesthetics, defaults, makeLayer, poly, sf, toStrictMode,
    __hasProp = Object.prototype.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

  poly = this.poly || {};

  sf = poly.scaleFns;

  aesthetics = ['x', 'y', 'color', 'size', 'opacity', 'shape', 'id'];

  defaults = {
    'x': sf.novalue(),
    'y': sf.novalue(),
    'color': 'steelblue',
    'size': 1,
    'opacity': 0.7,
    'shape': 1
  };

  toStrictMode = function(spec) {
    _.each(aesthetics, function(aes) {
      if (spec[aes] && _.isString(spec[aes])) {
        return spec[aes] = {
          "var": spec[aes]
        };
      }
    });
    return spec;
  };

  Layer = (function() {

    function Layer(layerSpec, statData) {
      var aes, _i, _len;
      this.spec = toStrictMode(layerSpec);
      this.mapping = {};
      this.consts = {};
      for (_i = 0, _len = aesthetics.length; _i < _len; _i++) {
        aes = aesthetics[_i];
        if (this.spec[aes]) {
          if (this.spec[aes]["var"]) this.mapping[aes] = this.spec[aes]["var"];
          if (this.spec[aes]["const"]) this.consts[aes] = this.spec[aes]["const"];
        }
      }
      this.defaults = defaults;
      this.precalc = statData;
      this.postcalc = null;
      this.geoms = null;
    }

    Layer.prototype.calculate = function() {
      this.layerDataCalc();
      return this.geomCalc();
    };

    Layer.prototype.layerDataCalc = function() {
      return this.postcalc = this.precalc;
    };

    Layer.prototype.geomCalc = function() {
      return this.geoms = {};
    };

    Layer.prototype.getValue = function(item, aes) {
      if (this.mapping[aes]) return item[this.mapping[aes]];
      if (this.consts[aes]) return sf.identity(this.consts[aes]);
      return sf.identity(this.defaults[aes]);
    };

    return Layer;

  })();

  Point = (function(_super) {

    __extends(Point, _super);

    function Point() {
      Point.__super__.constructor.apply(this, arguments);
    }

    Point.prototype.geomCalc = function() {
      var _this = this;
      return this.geoms = _.map(this.postcalc, function(item) {
        var evtData;
        evtData = {};
        _.each(item, function(v, k) {
          return evtData[k] = {
            "in": [v]
          };
        });
        return {
          geom: {
            type: 'point',
            x: _this.getValue(item, 'x'),
            y: _this.getValue(item, 'y'),
            color: _this.getValue(item, 'color')
          },
          evtData: evtData
        };
      });
    };

    return Point;

  })(Layer);

  Line = (function(_super) {

    __extends(Line, _super);

    function Line() {
      Line.__super__.constructor.apply(this, arguments);
    }

    Line.prototype.layerDataCalc = function() {
      this.ys = this.mapping['y'] ? _.uniq(_.pluck(this.precalc, this.mapping['y'])) : [];
      return this.postcalc = this.precalc;
    };

    Line.prototype.geomCalc = function() {
      var datas, group, k,
        _this = this;
      group = (function() {
        var _i, _len, _ref, _results;
        _ref = _.difference(_.keys(this.mapping), ['x', 'y']);
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          k = _ref[_i];
          _results.push(this.mapping[k]);
        }
        return _results;
      }).call(this);
      datas = poly.groupBy(this.postcalc, group);
      return this.geoms = _.map(datas, function(data) {
        var evtData, item;
        evtData = {};
        _.each(group, function(key) {
          return evtData[key] = {
            "in": [data[0][key]]
          };
        });
        return {
          geom: {
            type: 'line',
            x: (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                item = data[_i];
                _results.push(this.getValue(item, 'x'));
              }
              return _results;
            }).call(_this),
            y: (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                item = data[_i];
                _results.push(this.getValue(item, 'y'));
              }
              return _results;
            }).call(_this),
            color: _this.getValue(data[0], 'color')
          },
          evtData: evtData
        };
      });
    };

    return Line;

  })(Layer);

  makeLayer = function(layerSpec, statData) {
    switch (layerSpec.type) {
      case 'point':
        return new Point(layerSpec, statData);
      case 'line':
        return new Line(layerSpec, statData);
    }
  };

  poly.layer = {
    toStrictMode: toStrictMode,
    makeLayer: makeLayer
  };

  this.poly = poly;

}).call(this);