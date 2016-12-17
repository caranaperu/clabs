/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de las cotizaciones.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinCotizacionWindow", "WindowGridListExt");
isc.WinCotizacionWindow.addProperties({
    ID: "winCotizacionWindow",
    title: "Cotizaciones",
    width: 800,
    height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "CotizacionList",
            alternateRecordStyles: true,
            dataSource: mdl_cotizacion,
            autoFetchData: true,
            fetchOperation: 'fetchJoined',
            fields: [
                {
                    name: "cotizacion_numero",
                    width: '10%',
                    filterOperator: "equals"
                },
                {
                    name: "cotizacion_fecha",
                    width: '10%',
                    filterOperator: "equals"
                },
                {
                    name: "moneda_descripcion",
                    width: '30%'
                },
                {
                    name: "cliente_razon_social",
                    width: '50%'
                }
            ],
            getCellCSSText2: function(record, rowNum, colNum) {
                if (record.insumo_costo < 0) {
                    return "font-weight:bold; color:red;";
                }
            },
            initialCriteria: {
                _constructor: "AdvancedCriteria",
                operator: "and",
                criteria: [{
                    fieldName: 'empresa_id',
                    value: glb_empresaId,
                    operator: 'equals'
                }]
            },
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both'
           // sortField: 'cotizacion_numero'

        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
