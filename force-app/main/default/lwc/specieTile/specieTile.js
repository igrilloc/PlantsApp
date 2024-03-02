import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class SpeciesTile extends NavigationMixin(LightningElement) {
  /*
        specie = {
            Name: 'Jazmin',
            Description__c: 'Olorosa y bonita planta trepadora',
            Image_URL__c: 'https://i.pinimg.com/originals/88/a4/9f/88a49f73cb34bb49ea799087ad2fba15.jpg',
            Location__c: 'Indoors, Outdoors'
        }; 
    */

  @api specie;

  get isOutdoor() {
    return this.specie.Location__c.includes("Outdoors");
  }

  get isIndoor() {
    return this.specie.Location__c.includes("Indoors");
  }

  navigateToRecordViewPage() {
    // View a custom object record
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.specie.Id,
        objectApiName: "Species__c", // objectApiName is optional
        actionName: "view"
      }
    });
  }
}
