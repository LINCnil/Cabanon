import React from 'react';

export default class InfoCredits extends React.Component {
  constructor(props){
    super(props);
  }

  render(){
    return (
        <div className="info--part">
          <h3>Crédits</h3>
          <p>Cabanon est un projet mené par Vincent Toubiana et Estelle Hary dans le cadre des activités du LINC et de la CNIL.
          </p>
          <a href="https://www.cnil.fr/" target="_blank"> <img src='/src/assets/img/logo-cnil.png' className="img-logo"/></a>
          <a href="https://linc.cnil.fr/" target="_blank"> <img src='/src/assets/img/logo-linc.png' className="img-logo"/></a>
        </div>
    )
  }
}
