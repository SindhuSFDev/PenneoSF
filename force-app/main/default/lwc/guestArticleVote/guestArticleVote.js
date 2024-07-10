import { LightningElement, api } from 'lwc';
import GuestArticleVoteCss from '@salesforce/resourceUrl/GuestArticleVoteCss';
import { loadStyle } from 'lightning/platformResourceLoader';

import existsVoteResult from '@salesforce/apex/GuestArticleVoteController.existsVoteResult';
import vote from '@salesforce/apex/GuestArticleVoteController.vote';
import getUpVoteCount from '@salesforce/apex/GuestArticleVoteController.getUpVoteCount';


const COOKIE_KEY = 'guest_user_id';

export default class GuestArticleVote extends LightningElement {
    @api recordId;

    @api message_ask;
    @api message_thankyou;
    @api label_choice_yes;
    @api label_choice_no;

    isLoaded = false; // Prevent DOM rendering until the query finishes
    isVoted = false;
    isCompleted = false;
    hasError = false; // For future use
    currentGuestUserId = '';
    upVotes = 0; // upvotes
    articleName = '';
    language = '';
    submitComments = false;
    vote = false;
    comments = '';
    heading ='';
    subheading = '';
    Vote_Yes = '';
    Vote_No = '';
    feedback = '';
    placeholder = '';
    submit = '';

    connectedCallback() {
        //loadStyle(this, GuestArticleVoteCss);
        this.setOnLoadParams();
        this.currentGuestUserId = this.getCookie(COOKIE_KEY);
        console.log('User Id - ',this.currentGuestUserId);
        if (!this.currentGuestUserId) {
            this.currentGuestUserId = this.setCookie(
                COOKIE_KEY,
                this.generateUUID()
            );
        }
        console.log('User Id 2 - ',this.currentGuestUserId);
        //this.isLoaded = true;
        existsVoteResult({
            articleVersionId: this.articleName,
            guestUserId: this.currentGuestUserId
        }).then((result) => {
            this.isVoted = result;
            this.isLoaded = true;
        });
        /*
        getUpVoteCount({
            articleVersionId: this.recordId,
        }).then((result) => {
            this.upVotes = result;
        });
        */
    }

    setOnLoadParams(){
        var sPageURL = window.location.href; //You get the whole decoded URL of the page.
        var url = new URL(sPageURL);
        console.log('lANGUAGE GOT - '+url.searchParams.get("language"));
        this.language = url.searchParams.get("language") ? url.searchParams.get("language") : 'en_US';

        var sURLVariables = sPageURL.split('/article/'); //Split by & so that you get the key value pairs separately in a list       
        var sParameterName = sURLVariables[1];
        
        if(sParameterName.includes('?')){
            var langArticles = sParameterName.split('?');
            sParameterName = langArticles[0];
        }
        
        this.articleName = sParameterName;
        this.heading = this.language == 'en_US' ? 'DID THIS ARTICLE SOLVE YOUR ISSUE?' : 'LØSTE DENNE ARTIKEL DIT PROBLEM?';
        this.subheading = this.language == 'en_US' ? 'Let us know so we can improve!' :  'Giv os besked, så vi kan forbedre os!';
        this.Vote_Yes = this.language == 'en_US' ? 'Yes' : 'Ja';
        this.Vote_No = this.language == 'en_US' ? 'No' : 'Ingen';
        this.feedback = this.language == 'en_US' ? 'Thank you for your feedback!' : 'Tak for din feedback!';
        this.placeholder = this.language == 'en_US' ? 'type here...' : 'Skriv her...';
        this.submit = this.language == 'en_US' ? 'Submit' : 'Indsend';
    }

    getCookie(key) {
        const cookieString = '; ' + document.cookie;
        const parts = cookieString.split('; ' + key + '=');
        if (parts.length === 2) {
            return parts
                .pop()
                .split(';')
                .shift();
        }
        return null;
    }

    setCookie(key, value) {
        document.cookie = `${key}=${value}; path=/`;
        return value;
    }

    generateUUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
            const r = (Math.random() * 16) | 0,
                v = c === 'x' ? r : (r & 0x3) | 0x8;
            return v.toString(16);
        });
    }

    handleVote(event){
        debugger;
        var buttons = this.template.querySelectorAll('.feedback-button');
        buttons.forEach(but =>{
            but.classList.remove('slds-button_brand');
        })
        event.target.classList.add('slds-button_brand');
        console.log('Vote - '+event.currentTarget.dataset.vote);
        this.vote = event.currentTarget.dataset.vote == 'Yes'? true : false; 
        this.submitComments = true;
    }

    handleSubmit(event){
        this.comments = this.template.querySelector("lightning-textarea").value;
        console.log('Comments - ',this.comments);
        console.log('Final Vote - ',this.vote);
        console.log('Language - ',this.language);

        vote({
            articleURL: this.articleName,
            language : this.language,
            guestUserId: this.currentGuestUserId,
            isUpvoted: this.vote,
            comments : this.comments
        })
            .then((res) => {
                if(res == 'Success'){
                    this.isVoted = true;
                    this.isCompleted = true;
                }else{
                    this.isVoted = true;
                    this.hasError = true;
                }
            })
            .catch(() => {
                this.isVoted = true;
                this.hasError = true;
            });
    }



    // Previous Version
    upvote() {
        vote({
            articleVersionId: this.recordId,
            guestUserId: this.currentGuestUserId,
            isUpvoted: true
        })
            .then(() => {
                this.isVoted = true;
                this.isCompleted = true;
                getUpVoteCount({
                    articleVersionId: this.recordId,
                }).then((result) => {
                    this.upVotes = result;
                });
            })
            .catch(() => {
                this.hasError = true;
            });
    }

    downvote() {
        vote({
            articleVersionId: this.recordId,
            guestUserId: this.currentGuestUserId,
            isUpvoted: false
        })
            .then(() => {
                this.isVoted = true;
                this.isCompleted = true;
                getUpVoteCount({
                    articleVersionId: this.recordId,
                }).then((result) => {
                    this.upVotes = result;
                });
            })
            .catch(() => {
                this.hasError = true;
            });
    }
}