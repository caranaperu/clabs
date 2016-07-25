/**
 * Clase especifica para la definicion de la ventana para
 * la grilla del tipo de cambio.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 * $Rev: 6 $
 */
isc.defineClass("WinTipoCambioWindow", "WindowGridListExt");
isc.WinTipoCambioWindow.addProperties({
    ID: "winTipoCambioWindow",
    title: "Tipo De Cambio",
    width: 500, height: 400,
    createGridList: function () {
        return isc.ListGrid.create({
            ID: "TipoCambioList",
            alternateRecordStyles: true,
            dataSource: mdl_tipocambio,
            autoFetchData: true,
            fields: [
                {name: "_moneda_descripcion_o", width: '20%'},
                {name: "_moneda_descripcion_d", width: '20%'},
                {
                    name: "tipo_cambio_fecha_desde", width: '20%',
                    filterEditorProperties: {
                        editorType: 'date',
                            useTextField: true,
                            operator: "greaterOrEqual"
                        }
                },
                {
                    name: "tipo_cambio_fecha_hasta", width: '20%',
                    filterEditorProperties: {
                        editorType: 'date',
                        useTextField: true,
                        operator: "lessOrEqual"
                    }
                },
                {name: "tipo_cambio_tasa", width: '20%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'tipo_cambio_fecha_desde'
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});