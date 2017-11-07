import React    from 'react';
import d3       from 'd3';
import _        from 'lodash';
import TaxiDot  from './TaxiDot';

var topojson =  require ('topojson');
var d3Geo =     require ('d3-geo');
var d3Scale =   require('d3-scale');
var d3Chromatic = require('d3-scale-chromatic')

//Setting the standard element for drawing a ZCTA
const Zcta = ({ path, feature, color, data, ehover, eout}) => {
  if(data) {
    return (<path d={path(feature)} style={{fill: color(data.taxis), fillOpacity: 1}} className={"zcta" + data.zcta + ""} onMouseEnter={ehover} onMouseOut={eout} />)
  } else{
    return null
  }
};

export default class ChloroMap extends React.Component {
  constructor(props){
    super(props);
    this.updateD3(props);
    this.hoverIn = this.hoverIn.bind(this)
    this.hoverOut = this.hoverOut.bind(this)
  }

  componentWillReceiveProps(newProps){
    this.updateD3(newProps);
  }

  updateD3(props){
    props.projection.translate([props.width / 2, props.height / 2])
  }
  //Highlight the ZCTA connected to the one hovered
  hoverIn(e){
    var hoverZctaValue = e.currentTarget.className.baseVal.substr(4,8);
    var t = d3.transition().duration(750);

    d3.select(".map-svg")
      .selectAll('path')
      .transition(t)
      .attr('opacity', 0.3)

    _.forEach(this.props.link, function(value){
      if(hoverZctaValue === value.zcta) {
        _.forEach(value.link, function(value){
           d3.select(".zcta" + value.zcta + "")
            .transition(t)
            .attr('opacity', 1)
        })
      }
    });
    d3.select("." + e.currentTarget.className.baseVal + "")
      .transition(t)
      .attr('opacity', 1)
  }
  hoverOut(e) {
    var t = d3.transition().duration(750);
    d3.select(".map-svg")
      .selectAll('path')
      .transition(t)
      .attr('opacity', 1);
  }

  render() {
    if(!this.props.nycTopoJson){
      return null;
    }
    else {
      const nyc = this.props.nycTopoJson,
            zctaMesh = topojson.mesh(nyc, nyc.objects.zcta, (a,b) => a!== b),
            nycZcta = topojson.feature(nyc, nyc.objects.zcta).features,
            color = this.props.color;

      return (
        <g>
          {nycZcta.map((feature) =>
            <Zcta path={this.props.path}
                  feature={feature}
                  key={feature.id}
                  color = {this.props.color}
                  data = {_.find(this.props.data, {zcta: feature.id})}
                  ehover = {this.hoverIn}
                  eout = {this.hoverOut} />
          )}
          <path d={this.props.path(zctaMesh)} className='zcta-borders' />
        </g>
      )
    }
  }
}
