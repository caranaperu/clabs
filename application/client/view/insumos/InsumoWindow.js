/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los insumos
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinInsumoWindow", "WindowGridListExt");
isc.WinInsumoWindow.addProperties({
    ID: "winInsumoWindow",
    title: "Insumos",
    width: 600, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "InsumoList",
            alternateRecordStyles: true,
            dataSource: mdl_insumo,
            autoFetchData: true,
            fields: [
                {name: "insumo_codigo", width: '10%'},
                {name: "insumo_descripcion",  width: '35%'},
                {name: "_tcostos_descripcion",  width: '20%'},
                {name: "_tinsumo_descripcion",  width: '20%'},
                {name: "_unidad_medida_descripcion",  width: '20%'},
                {name: "insumo_merma",  width: '15%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'insumo_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
