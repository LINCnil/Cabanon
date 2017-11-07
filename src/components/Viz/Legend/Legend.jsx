import React    from 'react';
import d3       from 'd3';

export default class InfoLegend extends React.Component {
  constructor(props){
    super(props)
  }

  render(){
    const d = this.props.color.range();
    //Determine the taxis number intervals
    const i = _.map(d, (value) => {
      value = this.props.color.invertExtent(value)
      return value
    })
    const domainReference = this.props.color.domain()
   return (
      <div className="info--part">
        <h3>Légende</h3>
        <svg width="260" height="30">
          <g className="colorCaption">
          {_.map(i, (value) => {
            return (
              <g><rect height="5"  width="37" x={_.indexOf(i, value)*37} style={{fill: this.props.color(value[0])}}/>
              <text x={_.indexOf(i, value)*37+38} y="20" textAnchor="end" fontSize="11" style={{fill:"#7d8390"}}>{domainReference[_.indexOf(i, value)]}</text></g>
            )
          })
          }
          </g>
        </svg>
        <p>L'échelle de couleur est calculée pour chaque horaire sélectionné,
          c'est à dire que les couleurs sont relatives aux données du jeu de
          donné visualisé. Ainsi,  d'une plage horaire à l'autre, une même
          couleur ne correspond pas nécessairement au même nombre de taxi.</p>
      </div>
    )
  }
}
