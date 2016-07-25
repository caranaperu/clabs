/**
 * Clase que extiende el normal funcionamiento del SelectItem standard
 * agregandolo un boton para refrescar el contenido de la misma.
 *
 * Al ser usada dentro de una forma o container el type sera selectExt
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
 *              {name: "cdoc_codigo", editorType: "selectExt", length: 50, width: "200",
 *                   valueField: "cdoc_codigo", displayField: "cdoc_descripcion",
 *                   optionDataSource: mdl_cdocumentos,
 *                   pickListWidth: 240,
 *                   completeOnTab: true}
 *          ]
 *      });
 *
 * @author Carlos Arana Reategui
 * @version 1.00
 * @since 1.00
 * $Date: 2014-02-14 15:17:06 -0500 (vie, 14 feb 2014) $
 */
isc.defineClass("SelectExtItem", isc.SelectItem);
isc.SelectExtItem.addProperties({
    initWidget: function() {
        this.Super("initWidget", arguments);
    },
    // Agregamos el icono
    icons: [{
            src: "[SKIN]/actions/refresh.png",
            showOver: true,
            hspace: 1,
            click: function(form, item) {
                // Forzamos la relectura indicando no usa cache (solo pase)
                if (item.optionDataSource) {
                    var cacheAllDataCopy = item.optionDataSource.cacheAllData;
                    console.log(cacheAllDataCopy);
                    item.optionDataSource.setCacheAllData(false);
                    item.fetchData(function(it, r, d, r) {
                        // restauramos
                        item.optionDataSource.setCacheAllData(cacheAllDataCopy);
                    });
                }
            }
        }]
});
