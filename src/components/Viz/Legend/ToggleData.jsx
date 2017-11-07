import React from 'react';
import uuid from 'uuid';
import ToggleList from './ToggleList';

export default class ToggleData extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      dataNav: [
        {
          id: "AD",
          text: 'Données anonymisées (G29)',
          use: 'selected'
        },
        {
          id: "UD",
          text: 'Données anonymisées (Uber)',
          use: 'deselected'
        },
        {
          id: "NYCOD",
          text: 'Données originales',
          use: 'deselected'
        }
      ]
    }
  }
  changeDataset(id) {
    this.setState({
    dataNav: this.state.dataNav.map(item => {
      if(item.id === id){
        item.use = 'selected';
      }
      else {
        item.use = 'deselected';
      }
      return item;
      })
    })
    this.props.selectData(id)
  }

  render() {
    const {dataNav} = this.state;
    return (
      <div className="info--part">
        <h3>Jeu de données</h3>
        <ToggleList
          dataNav={dataNav}
          changeClass={this.changeDataset.bind(this)}
        />
    </div>
    )
  }
}
