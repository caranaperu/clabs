/**
 * Definicion del modelo Para los atletas.
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2014-06-24 04:45:11 -0500 (mar, 24 jun 2014) $
 * $Rev: 245 $
 */
isc.RestDataSource.create({
    ID: "mdl_atletas",
    showPrompt: true,
    dataFormat: "json",
    fields: [
        {
            name: "atletas_codigo",
            primaryKey: "true",
            title: "Codigo",
            mask: '>AAAAAAAA',
            required: true
        },
        {
            name: "atletas_ap_paterno",
            title: "Apellido Paterno",
            required: true,
            validators: [{
                type: "regexp",
                expression: glb_RE_onlyValidText
            }]
        },
        {
            name: "atletas_ap_materno",
            title: "Apellido Materno",
            required: true,
            validators: [{
                type: "regexp",
                expression: glb_RE_onlyValidText
            }]
        },
        {
            name: "atletas_nombres",
            title: "Nombres",
            required: true,
            validators: [{
                type: "regexp",
                expression: glb_RE_onlyValidText
            }]
        },
        {
            name: "atletas_nombre_completo",
            title: "Apellidos,Nombres",
            required: false,
            validators: [{
                type: "regexp",
                expression: glb_RE_onlyValidTextWithComma
            }]
        },
        {
            name: "paises_codigo",
            title: "Pais",
            required: true,
            foreignKey: "mdl_paises.paises_codigo"
        },
        {
            name: "atletas_sexo",
            title: "Sexo",
            valueMap: ["M",
                       "F"],
            required: true
        },
        {
            name: "atletas_nro_documento",
            title: "D.N.I",
            mask: '########',
            required: true,
            validators: [{
                type: "lengthRange",
                min: 8,
                max: 8
            }]
        },
        {
            name: "atletas_nro_pasaporte",
            title: "Pasaporte",
            mask: '########',
            validators: [{
                type: "lengthRange",
                min: 7,
                max: 8
            }]
        },
        {
            name: "atletas_fecha_nacimiento",
            title: "Fec.Nacimiento",
            type: 'date',
            required: true
        },
        {
            name: "atletas_agno",
            title: "A&ntildeo",
            type: 'integer',
            required: false
        },
        {
            name: "atletas_telefono_casa",
            title: "Tlf.Casa",
            mask: glb_MSK_phone,
            validators: [{
                type: "lengthRange",
                min: 7,
                max: 13
            }]
        },
        {
            name: "atletas_telefono_celular",
            title: "Tlf.Celular",
            mask: glb_MSK_phone,
            validators: [{
                type: "lengthRange",
                min: 9,
                max: 13
            }]
        },
        {
            name: "atletas_email",
            title: "E-Mail",
            validators: [{
                type: "lengthRange",
                max: 150
            },
                {
                    type: "regexp",
                    expression: glb_RE_email
                }]
        },
        {
            name: "atletas_direccion",
            title: "Direccion",
            required: true,
            validators: [{
                type: "lengthRange",
                max: 250
            }]
        },
        {
            name: "atletas_observaciones",
            title: "Observaciones",
            validators: [{
                type: "lengthRange",
                max: 250
            }]
        },
        {
            name: "atletas_talla_ropa_buzo",
            title: "Talla Buzo",
            valueMap: ["XS",
                       "S",
                       "M",
                       "L",
                       "XL",
                       "XXL",
                       "XXL",
                       "??"],
            required: true
        },
        {
            name: "atletas_talla_ropa_poloshort",
            title: "Talla Polo/Short",
            valueMap: ["XS",
                       "S",
                       "M",
                       "L",
                       "XL",
                       "XXL",
                       "XXL",
                       "??"],
            required: true
        },
        {
            name: "atletas_talla_zapatillas",
            title: "Talla Zapatillas",
            required: false,
            type: 'float',
            validators: [{
                type: "floatRange",
                min: 4,
                max: 50
            },
                {
                    type: "floatPrecision",
                    precision: 2
                }]
        },
        {
            name: "atletas_norma_zapatillas",
            title: "Norma",
            valueMap: ["UK",
                       "US",
                       "NM",
                       "??"],
            required: true
        },
        {
            name: "atletas_url_foto",
            title: "URL foto",
            required: false,
            validators: [{
                type: "lengthRange",
                max: 300
            }]
        },
        {
            name: "atletas_protected",
            type: 'boolean',
            getFieldValue: function (r, v, f, fn) {
                return mdl_atletas._getBooleanFieldValue(v);
            },
            required: true
        }
    ],
    fetchDataURL: glb_dataUrl + 'atletasController?op=fetch&libid=SmartClient',
    addDataURL: glb_dataUrl + 'atletasController?op=add&libid=SmartClient',
    updateDataURL: glb_dataUrl + 'atletasController?op=upd&libid=SmartClient',
    removeDataURL: glb_dataUrl + 'atletasController?op=del&libid=SmartClient',
    operationBindings: [
        {
            operationType: "fetch",
            dataProtocol: "postParams",
            skipRowCount: true
        },
        {
            operationType: "remove",
            dataProtocol: "postParams"
        },
        {
            operationType: "add",
            dataProtocol: "postParams"
        },
        {
            operationType: "update",
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

    },
    /**
     * Caso especial para generar el JSON de un advanced criteria para ser pasada como parte del
     * POST.
     */
    transformRequest: function (dsRequest) {
        var data = this.Super("transformRequest", arguments);
        // Si esxiste criteria y se define que proviene de un advanced filter y la operacion es fetch,
        // construimos un objeto JSON serializado como texto para que el lado servidor lo interprete correctamente.
        if (data.criteria && data._constructor == "AdvancedCriteria" && data._operationType == 'fetch') {
            var advFilter = {};
            advFilter.operator = data.operator;
            advFilter.criteria = data.criteria;

            // Borramos datos originales que no son necesario ya que  seran trasladados al objeto JSON
            delete data.operator;
            delete data.criteria;
            delete data._constructor;

            // Creamos el objeto json como string para pasarlo al rest
            // finalmente se coloca como data del request para que siga su proceso estandard.
            var jsonCriteria = isc.JSON.encode(advFilter, {prettyPrint: false});
            if (jsonCriteria) {
                //console.log(jsonCriteria);
                data._acriteria = jsonCriteria;
            }
        }
        return data;
    }
});