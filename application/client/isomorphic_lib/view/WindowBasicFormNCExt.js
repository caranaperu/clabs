/**
 * Clase generica para la definicion de la ventana para
 * la edicion de los registros de una tabla. Basicamente
 * maneja los botones e inserta la forma que manipula los registros
 * para poder exponer algunos metodos requeridos por el controller.
 *
 * Basicamnete soporta una forma principal de ediciion de datos
 * instancia de la clase isc.DynamicFormExt
 *
 * Una grilla opcional con el detalle del registro en edicion de la forma principal
 * de la clase isc.DetailGridContainer la cual a su vez podra contener una
 * forma interna para la edicion de los items.
 *
 * Asi mismo manipula mas de un tabulador si se requiere.
 *
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape $
 * $Date: 2016-01-26 04:56:39 -0500 (mar, 26 ene 2016) $
 * $Rev: 376 $
 */
isc.defineClass("WindowBasicFormNCExt", "WindowBasicFormExt");
isc.WindowBasicFormNCExt.addProperties({
    _saveRecord: function () {
        // Se consulta si es posible de grabarse el registro.
        if (this._form.isAllowedToSave() === false) {
            return;
        }

        var me = this;

        // Si hubieran default parameters en la forma los pasamos a save data
        var reqParams = {};
        if (me._form.requestParams !== undefined) {
            reqParams = isc.clone(me._form.requestParams);
        }

        // Se envia los valores que contiene la forma que son fuente de input para grabacion.
        me._form.preSaveData(me._form.formMode, me._mantForm.getValues());
        var oldValues = me._form.getOldValues();

        me._form.saveData(function (dsResponse, data, dsRequest) {
            if (dsResponse.status === 0) {
                // Luego de grabar puede requerirse armar campos compuestos o virtuales
                // osea campos como descripciones de codigos foreign.
                // Observese que se pasa data ya que luego de grabar la data retornada del servidor es usada de base para
                // llenar los campos.
                // RECORDAR QUE SI LA FORMA DE EDICION SOLICITA OBERVAR EL DATASOURCE ; PREVIA A ESTA FUNCION
                // SE INVOCARA A prepareDataAfterSave de la forma.
                // Cuando este metodo es llamado los valores que vienen del record y son parte de la forma
                // YA SE ENCUENTRAN ACTUALIZADOS CON LOS VALORES RETORNADOS DEL SERVER , POR ENDE SOLO SERA NECESARIO
                // ACTUALIZAR DATOS VIRTUALES EN ESTE PUNTO.
                me._form.postSaveData(me._mantForm.formMode, data);

                if (me._form.isPostOperationDataRefreshMainListRequired(dsRequest.operationType)) {
                    me._refreshMainList();
                }
                me._mainWindow.afterFormRecordSaved(data, oldValues);

                if (me._form.formMode === 'add') {
                    var needCloseForm = false;
                    // Si la grilla de detalle esta definida para la forma,
                    // conectamos la forma principal a la grilla de detalle.
                    if (me._detailGrid !== undefined) {
                        // trasladamos las llavse de la forma interna a la forma principal
                        // para que la grilla tenga acceso a l llave de los datos del detalle
                        me._joinKeyFieldsCopyTo(me.joinKeyFields, 'form', me, undefined);

                        //  Copiamos las llaves al buffer local
                        me._lastJoinKeys = JSON.parse(JSON.stringify(me.joinKeyFields));

                        // Se inician algunos campos que requieren ser manipulados
                        // previo a su presentacion
                        me._form.postSetFieldsToEdit();


                        // Se actualizan la grilla poniendol en blanco , claro se supone
                        // que si estamos agregando no deben haber items , y finalmente
                        // se muestra la grilla
                        me.getDetailGrid().fetchData(me._detailGridGetCriteria(me._formWindow.joinKeyFields));

                        // Esta visible?
                        if (me.isDetailGridListVisible() === false) {
                            if (me.canShowTheDetailGridAfterAdd() === true) {
                                me.showDetailGridList();
                            } else {
                                needCloseForm = true;
                            }
                        }
                        // Dado que el add fue correcto y la pantalla queda abierta el boton de grabar lo
                        // desabilitamos hasta que haya cambios.
                        me.getFormButton('save').disable();
                        // Paso a mode edit
                        // e indico que de aqui en adelante el modo de grabacion sera update.
                        me._form.editRecord(me._mantForm.getValues());
                        me._form.setEditMode('edit');

                        // En el caso de algun show if exista
                        me._form.markForRedraw();
                        if (needCloseForm) {
                            me.hide();
                        }
                        return;
                    } else {
                        // En el caso de algun show if exista
                        me._form.markForRedraw();
                    }
                }
                // en todos los demas casos se cierra el mantenimiento.
                // previa consulta a la forma
                if (me._form.canCloseWindow(me._form.formMode)) {
                    me.hide();
                } else {
                    // Dado que el add fue correcto y la pantalla queda abierta el boton de grabar lo
                    // desabilitamos hasta que haya cambios.
                    me.getFormButton('save').disable();
                    // Paso a mode edit
                    // e indico que de aqui en adelante el modo de grabacion sera update.
                    me._form.editRecord(me._form.getValues());
                    me._form.setEditMode('edit');

                }
            }
            reqParams = undefined;
        }, reqParams);

    },
    // Inicialiamos los widgets interiores
    initWidget: function () {
        var me = this;

        this.Super("initWidget", arguments);

        this.getFormButton('save').addProperties({
            click: function (form, item) {
                me._saveRecord();
            }
        })


    }
});
