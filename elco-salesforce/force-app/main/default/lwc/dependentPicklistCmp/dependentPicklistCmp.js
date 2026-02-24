import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

export default class DependentPicklistCmp extends LightningElement {
    @api objectApiName;
    @api topFieldApiName;
    @api middleFieldApiName;
    @api label;
    @api required = false;
    @api topValue;
    @api value; // For pre-population

    @track _middleValue;
    @track middleFieldOptions = [];

    objectInfo;
    allPicklistValues;
    recordTypeId;

    @api
    get middleValue() {
        return this._middleValue;
    }
    set middleValue(val) {
        this._middleValue = val;
    }

    @wire(getObjectInfo, { objectApiName: '$objectApiName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            this.objectInfo = data;
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            console.error('Error loading object info:', error);
        }
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: '$objectApiName', recordTypeId: '$recordTypeId' })
    wiredPicklistValues({ error, data }) {
        if (data) {
            this.allPicklistValues = data.picklistFieldValues;
            this.filterOptions();
        } else if (error) {
            console.error('Error loading picklist values:', error);
        }
    }

    filterOptions() {
        if (!this.allPicklistValues || !this.middleFieldApiName) {
            return;
        }

        const middleFieldValues = this.allPicklistValues[this.middleFieldApiName];
        if (!middleFieldValues) {
            return;
        }

        // Check if this is a dependent picklist
        const middleFieldDef = this.objectInfo?.fields[this.middleFieldApiName];
        const isDependent = middleFieldDef && middleFieldDef.controllerName;

        if (!isDependent || !this.topValue) {
            // Not dependent or no controlling value - show all options
            this.middleFieldOptions = middleFieldValues.values.map(opt => ({
                label: opt.label,
                value: opt.value
            }));
            return;
        }

        // Find the controlling field values to get the index
        const topFieldValues = this.allPicklistValues[this.topFieldApiName];
        if (!topFieldValues) {
            return;
        }

        const topValueIndex = topFieldValues.values.findIndex(v => v.value === this.topValue);
        if (topValueIndex === -1) {
            this.middleFieldOptions = [];
            return;
        }

        // Filter dependent picklist values based on validFor
        this.middleFieldOptions = middleFieldValues.values
            .filter(opt => {
                if (!opt.validFor || opt.validFor.length === 0) {
                    return true; // Show if no dependency metadata
                }
                return opt.validFor.includes(topValueIndex);
            })
            .map(opt => ({
                label: opt.label,
                value: opt.value
            }));
    }

    handleChange(event) {
        this._middleValue = event.detail.value;
        // Dispatch to notify Flow
        const changeEvent = new CustomEvent('valuechange', {
            detail: { value: this._middleValue }
        });
        this.dispatchEvent(changeEvent);
    }

    @api
    validate() {
        if (this.required && !this._middleValue) {
            return {
                isValid: false,
                errorMessage: `${this.label} is required`
            };
        }
        return { isValid: true };
    }

    get hasOptions() {
        return this.middleFieldOptions && this.middleFieldOptions.length > 0;
    }

    get isDisabled() {
        return !this.hasOptions;
    }

    renderedCallback() {
        // Re-filter when topValue changes
        if (this.topValue && this.allPicklistValues) {
            this.filterOptions();
        }

        // Initialize with provided value if present
        if (this.value && !this._middleValue) {
            this._middleValue = this.value;
        }
    }
}
