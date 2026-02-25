import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { createRecord } from 'lightning/uiRecordApi';
import { RefreshEvent } from 'lightning/refresh';
import PCB_CONFIG_OBJECT from '@salesforce/schema/PCB_Configuration__c';
import ACCOUNT_FIELD from '@salesforce/schema/PCB_Configuration__c.Account__c';
import TIPOLOGIA_FIELD from '@salesforce/schema/PCB_Configuration__c.Tipologia_Prodotto__c';
import MATERIALE_FIELD from '@salesforce/schema/PCB_Configuration__c.Materiale__c';
import MATERIALE_CUSTOM_FIELD from '@salesforce/schema/PCB_Configuration__c.Materiale_Custom_Value__c';
import DIMENSIONI_FIELD from '@salesforce/schema/PCB_Configuration__c.Dimensioni_Array__c';
import SPESSORE_FIELD from '@salesforce/schema/PCB_Configuration__c.Spessore_Complessivo__c';
import SPESSORE_CUSTOM_FIELD from '@salesforce/schema/PCB_Configuration__c.Spessore_Custom_Value__c';
import RAME_FIELD from '@salesforce/schema/PCB_Configuration__c.Spessore_Rame_Esterni__c';
import RAME_CUSTOM_FIELD from '@salesforce/schema/PCB_Configuration__c.Rame_Custom_Value__c';
import FINISH_FIELD from '@salesforce/schema/PCB_Configuration__c.Finish__c';
import SOLDER_FIELD from '@salesforce/schema/PCB_Configuration__c.Solder_Specifico__c';
import SILKSCREEN_FIELD from '@salesforce/schema/PCB_Configuration__c.Silkscreen_Specifico__c';
import PISTA_FIELD from '@salesforce/schema/PCB_Configuration__c.Pista_Minima__c';
import FORO_FIELD from '@salesforce/schema/PCB_Configuration__c.Foro_Minimo__c';
import ISOLAMENTO_FIELD from '@salesforce/schema/PCB_Configuration__c.Isolamento_Minimo__c';
import ASPECT_FIELD from '@salesforce/schema/PCB_Configuration__c.Aspect_Ratio__c';
import CUSTOMER_CODE_FIELD from '@salesforce/schema/PCB_Configuration__c.Customer_Circuit_Code__c';
import INTERNAL_CODE_FIELD from '@salesforce/schema/PCB_Configuration__c.Internal_Circuit_Code__c';

export default class PcbConfigurator extends LightningElement {
    @api recordId; // Account ID from Quick Action
    @track currentStep = 1;

    // Configuration data
    @track config = {
        tipologia: '',
        materiale: '',
        materialeCustom: '',
        dimensioni: '',
        spessore: '',
        spessoreCustom: '',
        rame: '',
        rameCustom: '',
        finish: '',
        solderMask: '',
        silkscreen: '',
        pistaMinima: '',
        foroMinimo: '',
        isolamentoMinimo: '',
        aspectRatio: '',
        customerCode: '',
        internalCode: ''
    };

    // Picklist definitions with dependencies
    get tipologiaOptions() {
        return [
            { label: 'Rigido', value: 'Rigido' },
            { label: 'Flessibile', value: 'Flessibile' },
            { label: 'Rigido-Flessibile', value: 'Rigido-Flessibile' }
        ];
    }

    get materialeOptions() {
        const allOptions = {
            'Rigido': [
                { label: 'FR-4 Standard', value: 'FR-4 Standard' },
                { label: 'FR-4 High Tg', value: 'FR-4 High Tg' },
                { label: 'Rogers', value: 'Rogers' },
                { label: 'Alluminio (Metal Core)', value: 'Alluminio (Metal Core)' },
                { label: 'CEM-1', value: 'CEM-1' },
                { label: 'CEM-3', value: 'CEM-3' },
                { label: 'Custom', value: 'Custom' }
            ],
            'Flessibile': [
                { label: 'Polyimide', value: 'Polyimide' },
                { label: 'Custom', value: 'Custom' }
            ],
            'Rigido-Flessibile': [
                { label: 'FR-4 Standard', value: 'FR-4 Standard' },
                { label: 'FR-4 High Tg', value: 'FR-4 High Tg' },
                { label: 'Polyimide', value: 'Polyimide' },
                { label: 'Custom', value: 'Custom' }
            ]
        };
        return allOptions[this.config.tipologia] || [];
    }

    get dimensioniOptions() {
        // Dimensioni_Array__c is a Text field, not picklist
        // Providing common options as convenience
        return [
            { label: 'Singola', value: 'Singola' },
            { label: '2 pcs', value: '2 pcs' },
            { label: '4 pcs', value: '4 pcs' },
            { label: '6 pcs', value: '6 pcs' },
            { label: '8 pcs', value: '8 pcs' },
            { label: 'Custom', value: 'Custom' }
        ];
    }

    get spessoreOptions() {
        // Spessore Complessivo dipende da Materiale
        const allOptions = {
            'FR-4 Standard': [
                { label: '0.4 mm', value: '0.4 mm' },
                { label: '0.6 mm', value: '0.6 mm' },
                { label: '0.8 mm', value: '0.8 mm' },
                { label: '1.0 mm', value: '1.0 mm' },
                { label: '1.2 mm', value: '1.2 mm' },
                { label: '1.6 mm', value: '1.6 mm' },
                { label: '2.0 mm', value: '2.0 mm' },
                { label: '2.4 mm', value: '2.4 mm' },
                { label: '3.2 mm', value: '3.2 mm' },
                { label: 'Custom', value: 'Custom' }
            ],
            'FR-4 High Tg': [
                { label: '0.4 mm', value: '0.4 mm' },
                { label: '0.6 mm', value: '0.6 mm' },
                { label: '0.8 mm', value: '0.8 mm' },
                { label: '1.0 mm', value: '1.0 mm' },
                { label: '1.2 mm', value: '1.2 mm' },
                { label: '1.6 mm', value: '1.6 mm' },
                { label: '2.0 mm', value: '2.0 mm' },
                { label: '2.4 mm', value: '2.4 mm' },
                { label: '3.2 mm', value: '3.2 mm' },
                { label: 'Custom', value: 'Custom' }
            ],
            'Rogers': [
                { label: '0.8 mm', value: '0.8 mm' },
                { label: '1.6 mm', value: '1.6 mm' },
                { label: 'Custom', value: 'Custom' }
            ],
            'Alluminio (Metal Core)': [
                { label: '1.0 mm', value: '1.0 mm' },
                { label: '1.6 mm', value: '1.6 mm' },
                { label: 'Custom', value: 'Custom' }
            ],
            'Polyimide': [
                { label: '0.4 mm', value: '0.4 mm' },
                { label: '0.6 mm', value: '0.6 mm' },
                { label: '0.8 mm', value: '0.8 mm' },
                { label: '1.0 mm', value: '1.0 mm' },
                { label: 'Custom', value: 'Custom' }
            ],
            'CEM-1': [
                { label: '1.0 mm', value: '1.0 mm' },
                { label: '1.6 mm', value: '1.6 mm' },
                { label: 'Custom', value: 'Custom' }
            ],
            'CEM-3': [
                { label: '1.0 mm', value: '1.0 mm' },
                { label: '1.6 mm', value: '1.6 mm' },
                { label: 'Custom', value: 'Custom' }
            ],
            'Custom': [
                { label: 'Custom', value: 'Custom' }
            ]
        };
        return allOptions[this.config.materiale] || [];
    }

    get rameOptions() {
        return [
            { label: '0.5 oz (18 µm)', value: '0.5 oz (18 µm)' },
            { label: '1 oz (35 µm)', value: '1 oz (35 µm)' },
            { label: '2 oz (70 µm)', value: '2 oz (70 µm)' },
            { label: 'Custom', value: 'Custom' }
        ];
    }

    get finishOptions() {
        return [
            { label: 'HASL', value: 'HASL' },
            { label: 'HASL Lead Free', value: 'HASL Lead Free' },
            { label: 'ENIG', value: 'ENIG' },
            { label: 'ENEPIG', value: 'ENEPIG' },
            { label: 'OSP', value: 'OSP' },
            { label: 'Immersion Silver', value: 'Immersion Silver' },
            { label: 'Immersion Tin', value: 'Immersion Tin' },
            { label: 'Hard Gold', value: 'Hard Gold' },
            { label: 'Custom', value: 'Custom' }
        ];
    }

    get solderMaskOptions() {
        return [
            { label: 'Verde', value: 'Verde' },
            { label: 'Nero', value: 'Nero' },
            { label: 'Bianco', value: 'Bianco' },
            { label: 'Rosso', value: 'Rosso' },
            { label: 'Blu', value: 'Blu' },
            { label: 'Giallo', value: 'Giallo' },
            { label: 'Trasparente', value: 'Trasparente' },
            { label: 'Nessuno', value: 'Nessuno' },
            { label: 'Custom', value: 'Custom' }
        ];
    }

    get silkscreenOptions() {
        return [
            { label: 'Bianco', value: 'Bianco' },
            { label: 'Nero', value: 'Nero' },
            { label: 'Giallo', value: 'Giallo' },
            { label: 'Nessuno', value: 'Nessuno' },
            { label: 'Custom', value: 'Custom' }
        ];
    }

    // Progress indicator steps
    get steps() {
        return [
            { label: 'Tipologia', value: '1' },
            { label: 'Materiale', value: '2' },
            { label: 'Dimensioni', value: '3' },
            { label: 'Rame', value: '4' },
            { label: 'Finiture', value: '5' },
            { label: 'Specifiche', value: '6' },
            { label: 'Riepilogo', value: '7' }
        ];
    }

    get currentStepValue() {
        return String(this.currentStep);
    }

    // Show/hide steps
    get isStep1() { return this.currentStep === 1; }
    get isStep2() { return this.currentStep === 2; }
    get isStep3() { return this.currentStep === 3; }
    get isStep4() { return this.currentStep === 4; }
    get isStep5() { return this.currentStep === 5; }
    get isStep6() { return this.currentStep === 6; }
    get isStep7() { return this.currentStep === 7; }

    // Navigation buttons
    get isFirstStep() { return this.currentStep === 1; }
    get isLastStep() { return this.currentStep === 7; }
    get showMaterialeCustom() { return this.config.materiale === 'Custom'; }
    get showSpessoreCustom() { return this.config.spessore === 'Custom'; }
    get showRameCustom() { return this.config.rame === 'Custom'; }

    // Handle field changes
    handleTipologiaChange(event) {
        this.config.tipologia = event.detail.value;
        // Reset materiale when tipologia changes
        this.config.materiale = '';
        this.config.materialeCustom = '';
    }

    handleMaterialeChange(event) {
        this.config.materiale = event.detail.value;
        // Reset spessore when materiale changes (dependent picklist)
        this.config.spessore = '';
        this.config.spessoreCustom = '';
    }

    handleFieldChange(event) {
        const field = event.target.dataset.field;
        this.config[field] = event.detail.value;
    }

    // Navigation
    handleNext() {
        if (this.validateCurrentStep()) {
            if (this.currentStep < 7) {
                this.currentStep++;
            }
        }
    }

    handlePrevious() {
        if (this.currentStep > 1) {
            this.currentStep--;
        }
    }

    handleSave() {
        // Final validation before save
        if (!this.recordId) {
            this.showToast(
                'Errore',
                'Nessun Account associato. Impossibile salvare la configurazione.',
                'error',
                'sticky'
            );
            return;
        }

        if (!this.config.tipologia) {
            this.showToast(
                'Configurazione Incompleta',
                'Tipologia Prodotto è obbligatoria. Torna allo Step 1 per selezionarla.',
                'warning'
            );
            this.currentStep = 1;
            return;
        }

        if (!this.config.materiale) {
            this.showToast(
                'Configurazione Incompleta',
                'Materiale è obbligatorio. Torna allo Step 2 per selezionarlo.',
                'warning'
            );
            this.currentStep = 2;
            return;
        }

        // Build the record input
        const fields = {};
        fields[ACCOUNT_FIELD.fieldApiName] = this.recordId;
        fields[TIPOLOGIA_FIELD.fieldApiName] = this.config.tipologia;
        fields[MATERIALE_FIELD.fieldApiName] = this.config.materiale;
        if (this.config.materialeCustom) {
            fields[MATERIALE_CUSTOM_FIELD.fieldApiName] = this.config.materialeCustom;
        }
        if (this.config.dimensioni) {
            fields[DIMENSIONI_FIELD.fieldApiName] = this.config.dimensioni;
        }
        if (this.config.spessore) {
            fields[SPESSORE_FIELD.fieldApiName] = this.config.spessore;
        }
        if (this.config.spessoreCustom) {
            fields[SPESSORE_CUSTOM_FIELD.fieldApiName] = this.config.spessoreCustom;
        }
        if (this.config.rame) {
            fields[RAME_FIELD.fieldApiName] = this.config.rame;
        }
        if (this.config.rameCustom) {
            fields[RAME_CUSTOM_FIELD.fieldApiName] = this.config.rameCustom;
        }
        if (this.config.finish) {
            fields[FINISH_FIELD.fieldApiName] = this.config.finish;
        }
        if (this.config.solderMask) {
            fields[SOLDER_FIELD.fieldApiName] = this.config.solderMask;
        }
        if (this.config.silkscreen) {
            fields[SILKSCREEN_FIELD.fieldApiName] = this.config.silkscreen;
        }
        if (this.config.pistaMinima) {
            fields[PISTA_FIELD.fieldApiName] = parseFloat(this.config.pistaMinima);
        }
        if (this.config.foroMinimo) {
            fields[FORO_FIELD.fieldApiName] = parseFloat(this.config.foroMinimo);
        }
        if (this.config.isolamentoMinimo) {
            fields[ISOLAMENTO_FIELD.fieldApiName] = parseFloat(this.config.isolamentoMinimo);
        }
        if (this.config.aspectRatio) {
            fields[ASPECT_FIELD.fieldApiName] = parseFloat(this.config.aspectRatio);
        }
        if (this.config.customerCode) {
            fields[CUSTOMER_CODE_FIELD.fieldApiName] = this.config.customerCode;
        }
        if (this.config.internalCode) {
            fields[INTERNAL_CODE_FIELD.fieldApiName] = this.config.internalCode;
        }

        const recordInput = { apiName: PCB_CONFIG_OBJECT.objectApiName, fields };

        createRecord(recordInput)
            .then(record => {
                this.showToast(
                    'Successo!',
                    `Configurazione PCB salvata con successo! ID: ${record.id}`,
                    'success'
                );

                // Refresh the view to update related lists
                this.dispatchEvent(new RefreshEvent());

                // Close the modal
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                console.error('Save error:', error);

                // Extract detailed error message
                let errorMessage = 'Si è verificato un errore durante il salvataggio.';

                if (error.body) {
                    if (error.body.fieldErrors) {
                        // Field-specific errors
                        const fieldErrors = Object.keys(error.body.fieldErrors).map(field => {
                            const errors = error.body.fieldErrors[field];
                            return `${field}: ${errors.map(e => e.message).join(', ')}`;
                        });
                        errorMessage = 'Errori nei campi:\n' + fieldErrors.join('\n');
                    } else if (error.body.message) {
                        errorMessage = error.body.message;
                    } else if (error.body.output && error.body.output.errors) {
                        errorMessage = error.body.output.errors.map(e => e.message).join('\n');
                    }
                } else if (error.message) {
                    errorMessage = error.message;
                }

                this.showToast(
                    'Errore di Salvataggio',
                    errorMessage,
                    'error',
                    'sticky'
                );
            });
    }

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    validateCurrentStep() {
        let isValid = true;
        let message = '';

        // Check Account ID exists
        if (!this.recordId) {
            message = 'Errore: Nessun Account associato. Questo componente deve essere lanciato da un Account.';
            this.showToast('Errore di Configurazione', message, 'error');
            return false;
        }

        switch(this.currentStep) {
            case 1:
                if (!this.config.tipologia) {
                    message = 'Seleziona una tipologia di prodotto per continuare';
                    isValid = false;
                }
                break;
            case 2:
                if (!this.config.materiale) {
                    message = 'Seleziona un materiale per continuare';
                    isValid = false;
                }
                if (this.config.materiale === 'Custom' && !this.config.materialeCustom) {
                    message = 'Hai selezionato "Custom" - specifica il materiale personalizzato';
                    isValid = false;
                }
                break;
            case 3:
                // Step 3: Dimensioni e Spessore Complessivo
                if (!this.config.dimensioni) {
                    message = 'Seleziona le dimensioni dell\'array per continuare';
                    isValid = false;
                }
                if (!this.config.spessore) {
                    message = 'Seleziona lo spessore complessivo per continuare';
                    isValid = false;
                }
                if (this.config.spessore === 'Custom' && !this.config.spessoreCustom) {
                    message = 'Hai selezionato spessore "Custom" - specifica il valore';
                    isValid = false;
                }
                break;
            case 4:
                // Step 4: Spessore Rame Esterni
                if (!this.config.rame) {
                    message = 'Seleziona lo spessore del rame per continuare';
                    isValid = false;
                }
                if (this.config.rame === 'Custom' && !this.config.rameCustom) {
                    message = 'Hai selezionato spessore rame "Custom" - specifica il valore';
                    isValid = false;
                }
                break;
            case 5:
                // Step 5: Finitura Superficiale, Solder Mask, Silkscreen
                if (!this.config.finish) {
                    message = 'Seleziona la finitura superficiale per continuare';
                    isValid = false;
                }
                if (!this.config.solderMask) {
                    message = 'Seleziona il colore del solder mask per continuare';
                    isValid = false;
                }
                if (!this.config.silkscreen) {
                    message = 'Seleziona il colore del silkscreen per continuare';
                    isValid = false;
                }
                break;
            case 6:
                // Step 6: Specifiche Tecniche (opzionali, ma validazione formato numerico)
                if (this.config.pistaMinima && isNaN(this.config.pistaMinima)) {
                    message = 'Pista Minima deve essere un numero valido';
                    isValid = false;
                }
                if (this.config.foroMinimo && isNaN(this.config.foroMinimo)) {
                    message = 'Foro Minimo deve essere un numero valido';
                    isValid = false;
                }
                if (this.config.isolamentoMinimo && isNaN(this.config.isolamentoMinimo)) {
                    message = 'Isolamento Minimo deve essere un numero valido';
                    isValid = false;
                }
                if (this.config.aspectRatio && isNaN(this.config.aspectRatio)) {
                    message = 'Aspect Ratio deve essere un numero valido';
                    isValid = false;
                }
                break;
        }

        if (!isValid) {
            this.showToast('Attenzione', message, 'warning');
        }
        return isValid;
    }

    showToast(title, message, variant, mode = 'dismissable') {
        this.dispatchEvent(new ShowToastEvent({
            title,
            message,
            variant,
            mode
        }));
    }

    connectedCallback() {
        // Validate that component is launched from an Account
        if (!this.recordId) {
            this.showToast(
                'Errore di Configurazione',
                'Questo componente deve essere lanciato da un Account. Impossibile procedere.',
                'error',
                'sticky'
            );
        }
    }
}