/**
 * Clase que extiende el normal funcionamiento del ComboBoxItem standard
 * agregandolo un boton para refrescar el contenido de la misma.
 *
 * Al ser usada dentro de una forma o container el type sera comboBoxExt
 *
 *
 * @example
 *  this.form = isc.DynamicFormExt.create({
 *          ID: "formGerencia",
 *          formMode: this.formMode, // parametro de inicializacion
 *          keyFields: ['codigo'],
 *          saveButton: this.formButtons.members[1],
 *          focusInEditFld: 'descripcion',
 *          fields: [
 *              {name: "codigo", title: "Codigo", type: "text", required: true, width: "60", mask: ">AAA"},
 *              {name: "cdoc_codigo", editorType: "comboBoxExt", length: 50, width: "200",
 *                   valueField: "cdoc_codigo", displayField: "cdoc_descripcion",
 *                   optionDataSource: mdl_cdocumentos,
 *                   pickListFields: [{name: "cdoc_codigo", width: '20%'}, {name: "cdoc_descripcion", width: '80%'}],
 *                   pickListWidth: 240,
 *                   completeOnTab: true}
 *          ]
 *      });
 *
 * @author $Author: aranape $
 * @version  $Id: ComboBoxExtItem.js 360 2016-01-24 22:08:51Z aranape $
 * $Date: 2016-01-24 17:08:51 -0500 (dom, 24 ene 2016) $
 * $Rev: 360 $
 */
isc.defineClass("ComboBoxExtItem", isc.ComboBoxItem);
        isc.ComboBoxExtItem.addProperties({
        addUnknownValues: false,
        minimumSearchLength: 3,
        searchStringTooShortMessage: 'Ingrese al menos 3 caracteres....',
        initWidget: function () {
                this.Super("initWidget", arguments);
        },
        forceRefresh: function () {
            // Forzamos la relectura indicando no usa cache (solo pase)
            if (this.optionDataSource) {
                var cacheAllDataCopy = this.optionDataSource.cacheAllData;
                        this.optionDataSource.setCacheAllData(false);
                        this.fetchData(function (it, r, d, r) {
                        // restauramos
                        this.optionDataSource.setCacheAllData(cacheAllDataCopy);
                        });
                }
        },
        // Agregamos el icono
        icons: [{
                src: "[SKIN]/actions/refresh.png",
                showOver: false,
                hspace: 1,
                tabIndex: - 1,
                inline: true,
              //  inlineIconAlign: 'right',
                width: 12,
                height: 12,
                click: function (form, item) {
                    item.forceRefresh();
                }
        }]
});
