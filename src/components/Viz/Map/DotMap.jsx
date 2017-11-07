import React    from 'react';
import d3       from 'd3';
import _        from 'lodash';
import TaxiDot  from './TaxiDot'

var topojson =  require ('topojson');
var d3Geo =     require ('d3-geo');
var d3Scale =   require('d3-scale')

//Standard element to draw the map background
const Zcta = ({ path, feature }) => {
    return (<path d={path(feature)} style={{fill: "#000"}}/>)
};

export default class DotMap extends React.Component {
  constructor(props){
    super(props);
    this.updateD3(props);
  }

  componentWillReceiveProps(newProps){
    this.updateD3(newProps);
  }

  updateD3(props){
    props.projection.translate([props.width / 2, props.height / 2])
  }

  render() {
    if(!this.props.nycTopoJson){
      return null;
    } else {
      const nyc = this.props.nycTopoJson,
            zctaMesh = topojson.mesh(nyc, nyc.objects.zcta, (a,b) => a!== b),
            nycZcta = topojson.feature(nyc, nyc.objects.zcta).features;
      return (
          <g>
            {nycZcta.map((feature) =>
              <Zcta path={this.props.path}
                    feature={feature}
                    key={feature.id}/>
            )}
            <path d={this.props.path(zctaMesh)} className='zcta-borders' />
            <TaxiDot data={this.props.data} projection={this.props.projection} path={this.props.path} />
          </g>
      )
    }
  }
}
