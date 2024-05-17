import { LightningElement, api } from 'lwc';

const COLUMN_URL = 'componentUrl';
const COLUMN_NAME = 'componentLabel';
const TYPE_CUSTOM_FIELD = 'CustomField';
const TYPE_RECORD_TYPE = 'RecordType';

export default class DeploymentChecklistSection extends LightningElement {
    @api columns = [];
    @api sectionData = [];
    @api sectionLabel;
    @api sectionName;

    selectedComponents = [];
    selectedChecklistRows = [];
    sortedBy;
    sortDirection;

    connectedCallback() {
        //default checkbox selections on load
        const self = this;
        this.sectionData.forEach(function(item) {
            self.selectedChecklistRows.push(item.componentId);
        });
        //adjust column remove link on new items
        if (this.hideSelection) {
            const columns = JSON.parse(JSON.stringify(this.columns));
            const urlIndex = columns.findIndex(column => column.type === 'url' && column.fieldName === COLUMN_URL);
            if (urlIndex) {
                columns[urlIndex].fieldName = COLUMN_NAME;
                columns[urlIndex].type = 'text';
                delete columns[urlIndex].typeAttributes;
                this.columns = columns;
            }
        }
    }

    get hideSelection() {
        return this.sectionName === TYPE_CUSTOM_FIELD || this.sectionName === TYPE_RECORD_TYPE;
    }

    /**
     * Datatable row checkbox selected event handler
     */
    rowSelected(event) {
        //fire event to parent component
		this.dispatchEvent(new CustomEvent('rowselection', { detail: 
            {
                sectionName: this.sectionName,
                selectedRows: event.detail.selectedRows
            }
        }));
    }

    /**
     * COLUMN SORTING FUNCTIONS
     **/
    updateColumnSorting(event) {
        const fieldName = event.detail.fieldName;
        const sortDirection = event.detail.sortDirection;
        const data = JSON.parse(JSON.stringify(this.sectionData));
        this.sortedBy = fieldName;
        this.sortDirection = sortDirection;
        this.sectionData = this.sortData(fieldName, sortDirection, data);
    }

    sortData(fieldName, sortDirection, data) {
        //url correction sort by name
        fieldName = fieldName === COLUMN_URL ? COLUMN_NAME : fieldName;
        const reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        return data;
    }

    sortBy(field, reverse, primer) {
        const key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            // eslint-disable-next-line no-return-assign, no-sequences
            return a = key(a) || "", b = key(b) || "", reverse * ((a > b) - (b > a));
        }
    }
}