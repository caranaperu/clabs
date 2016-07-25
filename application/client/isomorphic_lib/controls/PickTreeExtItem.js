/**
 * Clase que extiende el normal funcionamiento del PickTreeItem standard
 * agregandolo un boton para refrescar el contenido de la misma.
 *
 * Al ser usada dentro de una forma o container el type sera pickTreeExt
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
 *              {name: "dependencia", title: "Dependencia", type: "pickTreeExt", optionDataSource: mdl_jerarquia_entidad,
 *                   emptyMenuMessage: '', length: 120, width: 200, canSelectParentItems: false, valueField: 'codigo',
 *                   displayField: "descripcion", loadDataOnDemand: false, cellHeight: 20, required: true
 *              }
 *          ]
 *      });
 *
 * @author Carlos Arana Reategui
 * @version 1.00
 * @since 1.00
 * $Date: 2014-02-11 18:50:24 -0500 (mar, 11 feb 2014) $
 */
isc.defineClass("PickTreeExtItem", isc.PickTreeItem);
isc.PickTreeExtItem.addProperties({
    initWidget: function() {
        this.Super("initWidget", arguments);
    },
    // Agregamos el icono
    icons: [{
                src: "[SKIN]/actions/refresh.png",
                showOver: true,
                hspace: 1,
                click: function(form, item) {
                    // fetchData genera la relecctua de los datos pero no hace update
                    // de  los elementos visuales.
                    //    item.fetchData();

                    // Este metodo funcion , forzando la relectura cuando se vuelva a abrir la list
                    // en forma automatica.
                    // Es un HACK.
                    if (item.canvas !== null && item.canvas.menu !== null) {
                        item.canvas.menu.destroy();
                        item.canvas.menu = null;
                    }

                }
            }
        ]
});
