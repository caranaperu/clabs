/**
 * Definicion del modelo para los paises
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-29 21:13:31 -0500 (dom, 29 jun 2014) $
 */
isc.RestDataSource.create({
    ID: "mdl_paises",
    showPrompt: true,
    dataFormat: "json",
    //   cacheAllData: true, // Son datos pequeños hay que evitar releer
    fields: [
        {
            name: "paises_codigo",
            title: "Codigo",
            primaryKey: "true",
            required: true
        },
        {
            name: "paises_descripcion",
            title: "Descripcion",
            required: true,
            validators: [{
                type: "regexp",
                expression: glb_RE_onlyValidText
            }]
        },
        {
            name: "paises_entidad",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_paises._getBooleanFieldValue(v);
            },
            required: true
        },
        {
            name: "regiones_codigo",
            foreignKey: "mdl_regiones.regiones_codigo",
            required: true
        },
        {
            name: "paises_use_apm",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_paises._getBooleanFieldValue(v);
            },
            required: true
        },
        {
            name: "paises_use_docid",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_paises._getBooleanFieldValue(v);
            },
            required: true
        }

    ],
    fetchDataURL: glb_dataUrl + 'paisesController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'paisesController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'paisesController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'paisesController?op=del&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams"
        },
        {
            operationType: "add",
            dataProtocol: "postParams"
        },
        {
            operationType: "update",
            dataProtocol: "postParams"
        },
        {
            operationType: "remove",
            dataProtocol: "postParams"
        }
    ],
    /**
     * Normalizador de valores booleanos ya que el backend pude devolver de diversas formas
     * segun la base de datos.
     */
    _getBooleanFieldValue: function (value) {
        //  console.log(value);
        if (value !== 't' && value !== 'T' && value !== 'Y' && value !== 'y' && value !== 'TRUE' && value !== 'true' && value !== true) {
            return false;
        } else {
            return true;
        }

    }
});