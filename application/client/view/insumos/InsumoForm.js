/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de las regiones atleticas.
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
    width: 470, height: 265,
    createForm: function(formMode) {
        return isc.DynamicFormExt.create({
            ID: "formInsumo",
            numCols: 2,
            colWidths: ["120", "280"],
            fixedColWidths: true,
            padding: 5,
            dataSource: mdl_insumo,
            formMode: this.formMode, // parametro de inicializacion
            keyFields: ['insumo_codigo'],
            saveButton: this.getFormButton('save'),
            focusInEditFld: 'insumo_descripcion',
            addOperation: 'readAfterSaveJoined',
            updateOperation:'readAfterSaveJoined',
            fields: [
                {name: "insumo_codigo",  type: "text", showPending: true, width: "75", mask: ">LLLLLLLLLL"},
                {name: "insumo_descripcion",  showPending: true, length: 60, width: "260"},
                {name: "tinsumo_codigo",  editorType: "comboBoxExt",showPending: true, width: "120",
                    valueField: "tinsumo_codigo", displayField: "tinsumo_descripcion",
                    optionDataSource: mdl_tinsumo,
                    pickListFields: [{name: "tinsumo_codigo", width: '30%'}, {name: "tinsumo_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'insumo_descripcion'}]
                },
                {name: "tcostos_codigo",  editorType: "comboBoxExt",showPending: true, width: "120",
                    valueField: "tcostos_codigo", displayField: "tcostos_descripcion",
                    optionDataSource: mdl_tcostos,
                    pickListFields: [{name: "tcostos_codigo", width: '30%'}, {name: "tcostos_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'insumo_descripcion'}]
                },
                {name: "unidad_medida_codigo",  editorType: "comboBoxExt",showPending: true, width: "120",
                    valueField: "unidad_medida_codigo", displayField: "unidad_medida_descripcion",
                    optionDataSource: mdl_unidadmedida,
                    pickListFields: [{name: "unidad_medida_codigo", width: '30%'}, {name: "unidad_medida_descripcion", width: '70%'}],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'unidad_medida_descripcion'}]
                },
                {name: "insumo_merma",  showPending: true,width:'80'}
            ]
        });
    },
    initWidget: function() {
        this.Super("initWidget", arguments);
    }
});