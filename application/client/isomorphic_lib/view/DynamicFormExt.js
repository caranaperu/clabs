/**
 * Clase del para el manejo de formas SIMPLES usadas para mantener registros
 * de una tabla o posiblemente mas dependiendo de la complejidad, basicamente
 * es una clase utilitaria que maneja el estado de la forma o mode digase edicion , update
 * , etc activando o descativando el boton de grabar segun sea el caso asi como el estado de los
 * campos , segun la etapa de la edicion o adicion de un registro.
 *
 * Esta clase no puede ser usada por si sola y debe ser heredada por otra la cual define los campos,
 * botones , etc.
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
 *              {name: "descripcion", title: "Descripcion", required: true, length: 80, width: "260"} // creates a SelectItem
 *          ]
 *      });
 *
 * @author Carlos Arana Reategui
 * @version 1.00
 * @since 1.00
 * $Date: 2014-12-03 02:00:06 -0500 (mié, 03 dic 2014) $
 * TODO : Verificar porque el autofus no siempre selecciona el campo
 */
isc.defineClass("DynamicFormExt", isc.DynamicForm);
isc.DynamicFormExt.addProperties({
    // Defaults
    autoDraw: false,
    autoSize: false,
    disableValidation: false,
    errorOrientation: "right",
    validateOnExit: true,
    synchronousValidation: true,
    autoFocus: true,
    selectOnFocus: true,
    selectOnClick: true,
    /**
     * @cfg {String} formMode
     * Puede ser 'add','edit' y representa el modo incial de edicion
     * de la forma., por default es edit
     */
    formMode: "edit",
    /**
     * @cfg {String} openFormMode
     * Puede ser 'add','edit' y representa el modo incial en que se abrira la forma
     * al margen de lo que diga fomMode, es util cuando la forma siempre debe abrirse
     * en el mismo modo y en el caso que no se cierre  se haga edicion continua
     * sea formMode el que indique el status.
     * Solo sera respetado si esta forma no es invocada desde una grilla donde podria estarse
     * editando un registro por default sino mas bien cuando la forma es autonoma de otros
     * controles, ver caso de Empres o Postas.
     */
    openFormMode: "edit",
    /**
     * @cfg {String} focusInEditFld
     * El ID del campo que sera usado como default para tomar el foco
     * a iniciarse la edicion de un registro.
     */
    focusInEditFld: '',
    /**
     * @cfg {Array} keyFields
     * ID de la lista de campos que son llave en la base de datos , estos
     * campos no seran protegidos al agregarse uno nuevo , pero lo seran
     * al editarse un registro existente.
     */
    keyFields: [],
    /**
     * @cfg {String} saveButton
     * ID del boton a usarse para grabar el registro , esto le indicara
     * a esta clase que boton encender o apagar si las validaciones no estan
     * completas.
     */
    saveButton: undefined,
    /**
     * @cfg {String} deleteButton
     * ID del boton a usarse para eliminar el registro , esto le indicara
     * a esta clase que boton encender o apagar segun se este editando o no
     * un registro.
     */
    deleteButton: undefined,
    /**
     * @cfg {properties} requestParams
     * Lista de propiedades a enviar como parametros adicionales
     * a las operaciones CRUD , seran apendeados a cada una de ellas.
     * Formato : {params:{param1:"param1Value",param2:"param2Value"}}
     */
    requestParams: undefined,
    /**
     * @cfg {boolean} si se requiere que el metodo prepareDataAfterSave sea
     * invocado antes que postSaveData este atributo debe estar en true.
     * Usese solo cuando sea necesario.
     */
    observeDataSource: false,
    /**
     * Metodo a ser implementado enel caso que que la forma no se use en conjunto con un litgrid previo
     * de tal forma que provea la data inicial para inicializar la pantalla de ser necesario exista alguna.
     *
     */
    getInitialFormData: function () {
        //  console.log('implementame si deseas que haga algo');
    },
    /**
     * Metodo a ser implementado e nel caso que se requiera pre procesar algunos campos a editar
     * este metodo sera llamado previo a que los valores originales son cargados a la forma ,
     * dando oportunidad de modificar o armar campos especiales.
     *
     * @param Object fields conteniendo un record con los datos.
     */
    preSetFieldsToEdit: function (fields) {
        //  console.log('implementame si deseas que haga algo');
    },
    /**
     * Metodo a ser implementado e nel caso que se requiera procesar algunos campos a editar
     * este metodo sera llamado luego de que los valores originales son cargados a la forma ,
     * dando oportunidad de modificar o armar campos especiales.
     */
    postSetFieldsToEdit: function () {
        //  console.log('implementame si deseas que haga algo');
    },
    /**
     * Metodo a ser implementado en el caso que se requiera procesar algunos campos al momento previo
     * de agregar este metodo sera llamado luego de que los valores sean blanqueados para un nuevo registro
     * dando oportunidad de limpiar algunos campos que podrian ser parte de la forma pero no parte
     * del registro del modelo a grabar, o de pasar algunos valores que se requieren para inicializar el
     * mode = 'add'
     */
    setupFieldsToAdd: function (fieldsToAdd) {
        //  console.log('implementame si deseas que haga algo');
    },
    /**
     * Metodo a ser implementado el cual sera llamado antes de grabar o hacer update
     * retorna true si se permite la grabacion false de lo contrario.
     * Por default retorna true.
     *
     * @param Object record el registro que se esta editando. (Valores actuales)
     * @param Object oldRecord el registro que se esta editando. (Valores Originales no modificados)
     */
    isAllowedToSave: function (record, oldRecord) {
        return true;
    },
    /**
     * Metodo a ser implementado el cual sera llamado antes de abrir la pantalla de la forma
     * para edicion.
     * retorna true si se permite la edicion false de lo contrario.
     * Por default retorna true si hay un registro valido a editar.
     *
     * @param Object record el registro que se intenta editar.
     */
    isAllowedToEdit: function (record) {
        if (record) {
            return true;
        }
        return false;
    },
    /**
     * Metodo a ser implementado el cual sera llamado antes de eliminar un registro
     * retorna true si se permite la eliminacion false de lo contrario.
     * Por default retorna true.
     */
    isAllowedToDelete: function () {
        return true;
    },
    /**
     * Metodo a ser implementado enel caso que se requiera pre procesar los datos
     * antes de una grabacion, por default no hace nada
     *
     * @param String 'add' agregar,'edit' en update
     * @param Object record conteniendo los valores que se van a guardar en la persistencia.
     */
    preSaveData: function (mode, record) {
        //console.log('implementame si deseas que haga algo');
    },
    /**
     * Metodo a ser implementado en el caso que se requiera pre procesar los datos
     * luego de una grabacion pero antes que postSaveData sea llamado.
     *
     * La gran diferencia con postSaveData es que este es llamado ANTES QUE LOS CLIENT
     * CACHES sean actualizados !!!! , en otras palabras si se quiere garantizar que todos
     * los controeles que comparten el DataSource sean actualizado este metodo debe
     * ser implementado , por ejemplo un GridList con orderBy que simula un TREE actualiza
     * sus campos inmediatamente luego de que la grabacion es exitosa , pero antes de que
     * el callback en saveData sea llamado, dado que es durante este callback que se llama
     * a postSaveData en este caso no seria suficiente implementar dicho metodo sino este
     * metodo.
     *
     * IMPORTANTE: Dado que para que este metodo sea invocado por el controlador se requiere
     * observar el dataSource de esta forma y eso es mas costoso que el callback, el atributo
     * observeDataSource debera estar en true, de lo contrario no sera invocado.
     *
     * @param Object record conteniendo los valores que se van a guardar en la persistencia.
     */
    prepareDataAfterSave: function (record) {
        // Por default no hace nada
    },
    /**
     * Metodo a ser implementado enel caso que se requiera post procesar los datos
     * luego de una grabacion, por default no hace nada
     *
     * @param String mode 'add¡ agregar , 'edit' update.
     * @param Object record conteniendo los valores que se van a guardar en la persistencia.
     */
    postSaveData: function (mode, record) {
        //console.log('implementame si deseas que haga algo');
    },
    /**
     * Este metodo es llamado inmediatamente despues save,update o delete , en el caso que
     * por algun motivo especial se requiere forzar el refresh de la grilla que contiene el
     * record editandose.
     * Casos pueden ser que al grabar un registro nuevo , este agregue mas registros dependientes a la grilla principal.
     *  o que al eliminar un registro este elimina otros registros adicionales en la grilla principal que contiene
     *  el registro a eliminar.
     *  Si retorna true el controller se encargara de refescar la lista.
     *  Por default retorna false.
     *
     *  @param string operationType puese ser 'add','update','remove'
     *  @return boolean true si requiere repintarse , de lo contrario false.
     */
    isPostOperationDataRefreshMainListRequired: function (operationType) {
        return false;
    },
    /**
     * Metodo a ser invocado desde el controlador cada vez que una linea de la grilla
     * detalle sea correctamente grabada.
     * Da la oportunidad de actualizar alguna informacion luego de que la grilla
     * complete un registro.
     *
     * Los parametros son los mismos que el metodo editComplete de un ListGrid, ademas
     * se envia la instancia del gridList principal .
     */
    afterDetailGridRecordSaved: function (listControl, rowNum, colNum, newValues, oldValues) {
        // Sin implemetacion default
    },
    /**
     * Metodo a ser invocado desde el controlador previo a cerrar la ventana que contiene a este
     * form , se da la oprtunidad de evitarlo retornando true, se retorna false si no debe cerrarse.
     * Por default indica que si.
     *
     * @param {String} mode puede ser 'add','edit'
     */
    canCloseWindow: function (mode) {
        return true;
    },
    /**
     * Metodo hook llamado desde el container de la forma cuando un termina el fetch de un registro
     * para un campo determinado campo de la forma, esta sera llamada solo si se invoca
     * fetchFieldRecord en el container.
     * Esto sera util cuando se requiera manipular algunos campos que son necesarios pero dependen
     * de que un determinado registro de un campo este previamente cargado, dado que el ajax es asincronico
     * este metodo garantiza que sera invocado cuando realmente el registro este leido.
     *
     * @param {String} nombre del campo en esta forma.
     * @param {object} que representa el registro leido o null si no existe registro.
     *
     */
    fieldDataFetched: function (formFieldName, record) {
        return;
    },
    /**
     * Retorna el set de valores en edicion , en el caso de edit retornara los valores
     * originales , no los valores actualmente mostrados en la forma.
     *
     * @returns {object} Representados el set de valores en edicion.
     */
    getEditedRecord: function () {
        if (this.isNewRecord() === true) {
            return this.getValues();
        } else {
            return this.getOldValues();
        }
    },
    /**
     * Las operaciones permiten pasar parametros adicionales a las operaciones de
     * add,update o remove aqui puede retornarse los adicionales qe se desean psar al request.
     *
     * Importante , para que esto sea pasado  como partedel request el formato debe ser :
     * {'params': {'field1': fieldValue}}
     *
     * o
     *
     * {'params': {'params': [{'field1': fieldValue1},{'field2': fieldValue2}]}
     *
     * @param operation
     * @returns {null}
     */
    getAditionalPropertiesForOperation: function (operation) {
        return null;
    },
    /**
     * Metodo hook llamado desde el controlador cada vez que un item en la forma principal
     * es cambiado , aqui podra tomarse decisiones por ejemplo de cambiar la visibilidad
     * de campos en la forma que depena de un determinado valor de la forma principal.
     *
     * IMPORTANTE: Solo sera invocado cuando esta forma sea la forma que edita los campos de una grilla de
     * detalle. Si la forma es justo la forma principal usar simplemente itemChanged o changed en los
     * form items.
     *
     * @param {FormItem} item este tambien puede ser un combobox
     * @param {any} newValue
     * @returns true , SIEMPRE DEBE RETORNA TRUE
     */
    mainFormItemChanged: function (item, newValue) {
        return true;
    },
    initWidget: function (parms) {
        this.Super("initWidget", arguments);
        this.setEditMode(this.formMode);
    },
    /**
     * setea el modo de edicion dependiendo si es agregar o editar
     * prepara los elementos graficos de la forma como campos y botones
     * de acuerdo a la operacion.
     *
     * @param {String} mode puede ser 'add','edit'
     */
    setEditMode: function (mode) {
        this.formMode = mode;
        this._setFields();
        //console.log(this.saveButton)
        if (this.saveButton !== undefined) {
            this.saveButton.disable();
        }
        if (this.deleteButton !== undefined) {
            if (mode !== 'edit') {
                this.deleteButton.disable();
            } else {
                this.deleteButton.enable();
            }
        }
    },
    _disableProtectedFields: function () {
        if (this.keyFields.size() > 0) {
            var size = this.keyFields.size();
            for (i = 0; i < size; i++) {
                this.getItem(this.keyFields[i]).disable();
                this.getItem(this.keyFields[i]).canFocus = false;
            }
        }
    }
    ,
    _enableProtectedFields: function () {
        if (this.keyFields.size() > 0) {
            var size = this.keyFields.size();
            for (i = 0; i < size; i++) {
                this.getItem(this.keyFields[i]).enable();
                this.getItem(this.keyFields[i]).canFocus = true;

            }
        }
    }
    ,
    _setFields: function () {
        this.clearErrors();
        if (this.formMode === 'edit') {
            this._disableProtectedFields();
            this.focusInItem(this.getItem(this.focusInEditFld));
        } else {
            this._enableProtectedFields();
            this.editNewRecord();
            if (this.keyFields.size() > 0) {
                this.focusInItem(this.keyFields[0]);
            }

        }
    }
    ,
    handleHiddenValidationErrors: function (errors) {
        console.log(errors);
    }
})
;
