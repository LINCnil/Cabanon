import React    from 'react';
import d3       from 'd3';
import _        from 'lodash';
var topojson =  require ('topojson');
var d3Geo =     require ('d3-geo');
var d3Scale =   require('d3-scale');

//Standard element to draw a point (taxi) on the map
const Dot = ({path, data}) => {
    return (<circle fill="#2f64ff" r="0.5" cx={path.centroid(data)[0]} cy={path.centroid(data)[1]} style={{opacity: "0.5"}} />);
};

export default class TaxiDot extends React.Component {
  constructor(props){
    super(props);
  }

  render(){
    return(
      <g>
        {this.props.data.features.map((feature) =>
          <Dot path={this.props.path} data={feature} />
        )}
      </g>
    )

  }
}
