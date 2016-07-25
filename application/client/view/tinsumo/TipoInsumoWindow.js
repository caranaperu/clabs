/**
 * Clase especifica para la definicion de la ventana para
 * la grilla de los yipos de insumos.
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinTipoInsumoWindow", "WindowGridListExt");
isc.WinTipoInsumoWindow.addProperties({
    ID: "winTipoInsumoWindow",
    title: "Tipo Insumo",
    width: 500, height: 400,
    createGridList: function() {
        return isc.ListGrid.create({
            ID: "TipoInsumoList",
            alternateRecordStyles: true,
            dataSource: mdl_tinsumo,
            autoFetchData: true,
            fields: [
                {name: "tinsumo_codigo", title: "Codigo", width: '25%'},
                {name: "tinsumo_descripcion", title: "Nombre", width: '75%'}
            ],
            canReorderFields: false,
            showFilterEditor: true,
            autoDraw: false,
            canGroupBy: false,
            canMultiSort: false,
            autoSize: true,
            AutoFitWidthApproach: 'both',
            sortField: 'tinsumo_descripcion'
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});
