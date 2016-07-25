/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:42:57 -0500 (mar, 24 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_ciudades",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "ciudades_codigo", primaryKey: "true", required: true},
        {name: "ciudades_descripcion", title: "Descripcion", required: true,
            validators: [{type: "regexp", expression: glb_RE_onlyValidText}]
        },
        {name: "paises_codigo", foreignKey: "mdl_paises.paises_codigo", required: true},
        {name: "ciudades_altura", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_ciudades._getBooleanFieldValue(v);
            }},
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function(value) {
        //  console.log(value);
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    },
    fetchDataURL: glb_dataUrl + 'ciudadesController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'ciudadesController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'ciudadesController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'ciudadesController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
    ]
});