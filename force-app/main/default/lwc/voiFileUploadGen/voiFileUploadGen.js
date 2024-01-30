import { LightningElement, api, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import MY_CUSTOM_LABEL from '@salesforce/label/c.SiteUrl';
import SolarLoan from '@salesforce/resourceUrl/SolarLoan';
import removeContent from '@salesforce/apex/newVOIController.removeContent';
export default class VoiFileUploadGen extends LightningElement {
    @api conrecord;
    @api type;
    @api authtoken;
    @api voidetail;
    @api idtype = '';
    @track imageData = '';
    @api newImgData = '';
    @api newfileTyp = '';
    @track myRecordId;
    isUploadingFront = false;
    @track uploadingPercent = 0;
    @track isUpl = 'Uploading...';
    csLabel = MY_CUSTOM_LABEL;
    greenTick = SolarLoan + '/img/LargeDone.png';
    uploadIcon = SolarLoan + '/img/uploadiconSmall.png';
    delIcon = SolarLoan + '/img/deleteIcon.png';
    @track dataMap = [];
    @track isFront = false;
    @track isBack = false;
    @track isOther = false;
    @track attamps = 0;
    @track uploadedId = '';
    @track removeIndexName = '';
    fileDt;

    @api userAgent = navigator.userAgent;
    @track fileData = '';
    @track fileType = '';    


    get isIOSDevice() {        
        return /iPad|iPhone|iPod/.test(this.userAgent) && !window.MSStream;
    
    }
    
    connectedCallback() {
        var file = this.idtype;
        if(file == 'Front of your Driver\'s License'){
            this.isFront = true;
        }
        else if(file == 'Back of your Driver\'s License'){
            this.isBack = true;
        }
        else{
            this.isOther = true;
        }              
        this.myRecordId = this.voidetail.Id;
    }    

    showPreviewOpst(event) {
        const previewOpst = this.template.querySelector('.previewOpst');
        if (previewOpst) {
            previewOpst.style.display = 'block';
        }
    }

    hidePreviewOpst(event) {
        const previewOpst = this.template.querySelector('.previewOpst');
        if (previewOpst) {
            previewOpst.style.display = 'none';
        }
    }

    deleteImage(event){    
        this.removeIndexName = this.idtype;
        //this.idtype = '';      
        console.log('id++'+this.uploadedId);
       if(confirm('Are you sure you want to delete it?')){
            removeContent({docId : this.uploadedId})
            .then(result => {
                if(result == 'success'){
                    this.isUploadingFront = false;
                    this.imageData = '';
                    this.checkDlUploaded();
                    this.removeIndexName = '';
                }
            })
            .catch(error => {
                console.log(error);
            })
       }
    }

    handleUploadFinished(event) {

        this.isUploadingFront = true;
        const file = event.target.files[0];
        this.fileDt = file;
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            var filelst = file.name.split('.');                    
            var extension = filelst[filelst.length - 1];
            this.uploadFileToServer(base64, extension);
        }   
        reader.readAsDataURL(file)
    }


    uploadFileToServer(fileContents, typ) {
        try {
            //alert('methid call');
            const component = this;
            const recordInput = {
                Title: this.type + ' ' + this.conrecord.Name,
                VersionData: fileContents,
                PathOnClient: this.type + ' ' + this.conrecord.Name + '.' + typ,
                IsMajorVersion: true,
                FirstPublishLocationId: this.myRecordId//'0069h000006Pu20AAC'
            };

            const url = this.csLabel.replace(/''/g, '') + '/services/data/v39.0/sobjects/ContentVersion';
            const conVer_object = recordInput;
            const xhr = new XMLHttpRequest();
            xhr.open('POST', url, true);
            xhr.setRequestHeader('Authorization', 'Bearer ' + this.authtoken);
            xhr.setRequestHeader('Content-Type', 'application/json');

            xhr.upload.addEventListener("progress", function (evt) {
                if (evt.lengthComputable) {
                    //alert('methid in progress');
                    const percentComplete = (evt.loaded / evt.total) * 100;
                    component.uploadingPercent = percentComplete;
                    console.log('-----' + percentComplete);
                }
            }, false);

            xhr.onload = function () {
                //alert('0-0-0-', xhr.status);
                if (xhr.status === 201) {
                    //alert('methid success');
                    component.isUpl = 'Uploaded';
                    console.log('name===' + xhr.responseText);                    
                    let JsnData = JSON.parse(xhr.responseText);
                    console.log('name===-=-' +component.type);
                    component.uploadedId = JsnData.id
                    component.imageData = 'data:image/png;base64,' + fileContents;
                    component.checkDlUploaded();    
                    component.checkisErrorsolve();                    
                } else {
                    console.log('Error in Operation');
                    console.log('doc==' + xhr.responseText);
                }
            };

            xhr.onerror = function () {
                console.log('Error in Operation');
                console.log('doc==' + xhr.responseText);                
                if(component.attamps>1){
                    //alert('We have Found glitches in you internet!!!');
                    component.checkisErrorOnOperation();
                    component.isUploadingFront = false;
                }else{
                    component.uploadFileToServer(fileContents, typ);
                    component.attamps++;
                }
            };

            xhr.send(JSON.stringify(conVer_object));
        } catch (error) {
            console.log('---', error);
        }        
    }

    checkDlUploaded() {
        this.dispatchEvent(new CustomEvent('callparentfordl', {
            detail: {
                type: this.idtype,
                removetyp : this.removeIndexName
            }
        }));
    }

    checkisErrorOnOperation(){
         this.dispatchEvent(new CustomEvent('checkerror', {
            detail: {
                istr: true
            }
        }));
    }

    checkisErrorsolve(){
         this.dispatchEvent(new CustomEvent('checkerror', {
            detail: {
                istr: false
            }
        }));
    }


}