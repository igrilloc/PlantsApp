import { LightningElement, wire } from "lwc";
import getFilteredSpecies from "@salesforce/apex/SpeciesService.getFilteredSpecies";

export default class SpeciesList extends LightningElement {
  /* species = [
        {
            Name: 'Jazmin',
            Description__c: 'Olorosa y bonita planta trepadora',
            Image_URL__c: 'https://i.pinimg.com/originals/88/a4/9f/88a49f73cb34bb49ea799087ad2fba15.jpg',
            Location__c: 'Indoors, Outdoors'
        },
        {
            Name: 'Hierbabuena',
            Description__c: 'Arómatica que huele de maravilla, muy usada en la gastronomía, en la medicina popular y para hacer te',
            Image_URL__c: 'https://decoracionyjardines.com/wp-content/uploads/2017/02/cuidados-de-la-hierbabuena.jpg',
            Location__c: 'Indoors, Outdoors'
        },
        {
            Name: 'Poto',
            Description__c: 'Bonita planta de interior que no requiere muchos cuidados y se expandirá casi sin mirarla!',
            Image_URL__c: 'https://cdn2.cocinadelirante.com/sites/default/files/styles/gallerie/public/images/2020/10/cuidados-de-las-plantas-telefono.jpg',
            Location__c: 'Indoors, Outdoors'
        }
    ]; */

  // Properties, Getters and Setters
  searchText = "";

  // Lifecycle Hooks

  // Wire
  @wire(getFilteredSpecies, { searchText: "$searchText" })
  species;

  // Methods
  handleInputChange(event) {
    const searchTextAux = event.detail.value;
    // console.log('Texto recibido: ', searchTextAux);
    if (searchTextAux.length >= 3 || searchTextAux === "") {
      this.searchText = searchTextAux;
    }
  }
}
