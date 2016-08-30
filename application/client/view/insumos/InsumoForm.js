/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los insumos.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-27 17:27:42 -0500 (vie, 27 jun 2014) $
 * $Rev: 274 $
 */
isc.defineClass("WinInsumoForm", "WindowBasicFormExt");
isc.WinInsumoForm.addProperties({
    ID: "winInsumoForm",
    title: "Mantenimiento de Insumos",
    width: 585, height: 300,
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formInsumo",
            numCols: 4,
            colWidths: ["100", "120", "100", "220"],
            fixedColWidths: false,
            padding: 5,
            dataSource: mdl_insumo,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['insumo_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'insumo_descripcion',
            addOperation: 'readAfterSaveJoined',
            updateOperation: 'readAfterUpdateJoined',
            fields: [
                {name: "insumo_tipo", defaultValue:"IN", hidden: true},
                {name: "insumo_codigo", type: "text", showPending: true, width: "85", mask: ">LLLLLLLLLL"},
                {name: "insumo_descripcion", showPending: true, length: 60, width: "220"},
                {
                    name: "tinsumo_codigo", editorType: "comboBoxExt", showPending: true, width: "135",
                    valueField: "tinsumo_codigo", displayField: "tinsumo_descripcion",
                    optionDataSource: mdl_tinsumo,
                    pickListFields: [{name: "tinsumo_codigo", width: '30%'}, {
                        name: "tinsumo_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'insumo_descripcion'}]
                },
                {
                    name: "tcostos_codigo", editorType: "comboBoxExt", showPending: true, width: "120",
                    valueField: "tcostos_codigo", displayField: "tcostos_descripcion",
                    optionDataSource: mdl_tcostos,
                    pickListFields: [{name: "tcostos_codigo", width: '30%'}, {
                        name: "tcostos_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'insumo_descripcion'}],
                    startRow: true,
                    endRow: true
                },
                {
                    name: "unidad_medida_codigo_ingreso", editorType: "comboBoxExt", showPending: true, width: "120",
                    valueField: "unidad_medida_codigo", displayField: "unidad_medida_descripcion",
                    optionDataSource: mdl_unidadmedida,
                    pickListFields: [{name: "unidad_medida_codigo", width: '30%'}, {
                        name: "unidad_medida_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'unidad_medida_descripcion'}]
                },
                {name: "insumo_merma", showPending: true, width: '80'},
                {
                    name: "insumos_separator_01",
                    defaultValue: "Costo",
                    type: "section",
                    colSpan: 4,
                    width: "*",
                    //padding: 0,
                    canCollapse: false,
                    align: 'center',
                    itemIds: ["unidad_medida_codigo_costo","insumo_costo"]
                },
                {
                    name: "unidad_medida_codigo_costo", editorType: "comboBoxExt", showPending: true, width: "120",
                    valueField: "unidad_medida_codigo", displayField: "unidad_medida_descripcion",
                    optionDataSource: mdl_unidadmedida,
                    pickListFields: [{name: "unidad_medida_codigo", width: '30%'}, {
                        name: "unidad_medida_descripcion",
                        width: '70%'
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'unidad_medida_descripcion'}],
                    startRow: true
                },
                {name: "moneda_codigo_costo",  editorType: "comboBoxExt",showPending: true, width: "140",
                    valueField: "moneda_codigo", displayField: "moneda_descripcion",
                    optionDataSource: mdl_moneda,
                    pickListFields: [{name: "moneda_codigo", width: '30%'}, {name: "moneda_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'moneda_descripcion'}]
                },
                {name: "insumo_costo", showPending: true, width: '80'}
            ]//, cellBorder: 1
        });
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});