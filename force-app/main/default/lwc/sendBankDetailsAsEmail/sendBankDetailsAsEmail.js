import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

export default class EmailQuickAction extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isLoading = false;
    @api invoke() {
        var pageRef = {
            type: "standard__quickAction",
            attributes: {
                apiName: "Global.SendEmail",
            },
            state: {
                recordId: this.recordId,
                defaultFieldValues: encodeDefaultFieldValues({
                    Subject: "Penneo Bank Details",
                    HtmlBody: "Dear Customer,<br/><br/>"&
                                "As you requested here are the bank account details of penneo.<br/>"&
                                "Please do the payment using these details.<br/>"&
                                    "Reg no. 3001<br/>"&
                                    "Account no. 0012817541<br/>"&
                                    "IBAN : DK50 3000 0012 8175041 <br/>"&
                                    "BIC/SWIFT : DABADKK <br/><br/>"&
                                "Please let us know if you need any other details.<br/><br/>"&
                                "Thanks,<br/><br/>"&
                                "PENNEO A/S"
                }),
            },
        };

        this[NavigationMixin.Navigate](pageRef);
    }
}