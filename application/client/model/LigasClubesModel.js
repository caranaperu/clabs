/**
 * Definicion del modelo la relacion de clubes asociados a ligas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-03-25 11:34:07 -0500 (mar, 25 mar 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_ligasclubes",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {name: "ligasclubes_id", primaryKey: "true"},
        {name: "ligas_codigo", required: true, hidden: true, },
        {name: "clubes_codigo", required: true, hidden: true, foreignKey: "mdl_clubes.clubes_codigo"},
        {name: "clubes_descripcion"},
        {name: "ligasclubes_desde", type: 'date', required: true},
        {name: "ligasclubes_hasta", type: 'date'},
        {name: "activo", type: 'boolean', getFieldValue: function(r, v, f, fn) {
                return mdl_ligasclubes._getBooleanFieldValue(v);
            }},
    ],
    fetchDataURL: glb_dataUrl + 'ligasClubesController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'ligasClubesController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'ligasClubesController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'ligasClubesController?op=del&libid=SmartClient',
    operationBindings: [
        {operationType: "fetch", dataProtocol: "postParams"},
        {operationType: "add", dataProtocol: "postParams"},
        {operationType: "update", dataProtocol: "postParams"},
        {operationType: "remove", dataProtocol: "postParams"}
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
    /**
     * Dado que cuando se esita en grilla no se pasan todos los valores
     * y estos se conservan en _oldValues , copiamos todos los
     * de oldValues a la data a transmitir siempre que oldvalues este
     * este definida , lo cual sucede solo para el update.
     */
    transformRequest: function(dsRequest) {
        var data = this.Super("transformRequest", arguments);
        if (dsRequest.operationType == 'add' || dsRequest.operationType == 'update') {
            //  var data = isc.addProperties({}, dsRequest.data);
            // Solo para los valores que se encuentran en oldValues de no existir
            // se deja como esta.
            //    console.log(dsRequest.oldValues);
            for (var fieldName in dsRequest.oldValues) {
                if (data[fieldName] === undefined) {
                    data[fieldName] = dsRequest.oldValues[fieldName];
                }
                else if (data[fieldName] === null) {
                    data[fieldName] = '';
                }
            }
            return data;
        } else {
            return data;
        }
    }
});