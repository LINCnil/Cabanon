import React from 'react';

export default class InfoDescription extends React.Component {
  constructor(props){
    super(props);
  }

  render(){
    return (
        <div className="info--part">
          <h3>Cabanon</h3>
          <p>Cette carte représente la densité de taxi dans la ville de New York,
            se basant sur les données ouvertes publiées par la ville
            de New York en 2013.
          </p>
          <p>Dans le cas des données anonymisées, le nombre de taxi est représenté
            au moyen de la coloration de chaque zone ZCTA (cf. légende).
          </p>
          <p>Dans le cas des données originales, chaque taxi est représenté par
            un point correspondant au coordonnées de localisation du taxi.
          </p>
          <p>Trois jeux de données sont disponibles permettant de comparer
            différentes méthodes d'anonymisation avec les données originellement
            publiées.
          </p>
        </div>
    )
  }
}
