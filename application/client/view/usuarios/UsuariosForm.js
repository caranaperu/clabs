/**
 * Clase especifica para la definicion de la ventana para
 * la edicion de los registros de los usuarios
 *
 * @version 1.00
 * @since 1.00
 * $Author: aranape@gmail.com $
 * $Date: 2015-08-23 18:01:21 -0500 (dom, 23 ago 2015) $
 * $Rev: 63 $
 */
isc.defineClass("WinUsuariosForm", "WindowBasicFormExt");
isc.WinUsuariosForm.addProperties({
    ID: "winUsuariosForm",
    title: "Mantenimiento de Usuarios",
    width: 550, height: 245,
    joinKeyFields: [{fieldName: 'usuarios_id', fieldValue: ''}],
    createForm: function (formMode) {
        return isc.DynamicFormExt.create({
            ID: "formUsuarios",
            padding: 2,
            colWidths: [130, "*"],
            fixedColWidths: false,
            dataSource: mdl_usuarios,
            formMode: this.formMode, // parametro de inicializacion
            saveButton: this.getFormButton('save'),
            keyFields: ['usuarios_code'],
            focusInEditFld: 'usuarios_password',
            addOperation:'readAfterSaveJoined',
            updateOperation:'readAfterUpdateJoined',
            fields: [
                {name: "usuarios_code", width: 80, size: 15, showPending: true, endRow: true},
                {name: "usuarios_password", size: 20, width: 150, showPending: true, endRow: true},
                {name: "usuarios_nombre_completo", size: 250, width: 300, showPending: true, endRow: true},
                {
                    name: "empresa_id",
                    editorType: "comboBoxExt",
                    showPending: true,
                    width: "120",
                    valueField: "empresa_id",
                    displayField: "empresa_razon_social",
                    optionDataSource: mdl_empresa,
                    pickListFields: [{
                        name: "empresa_razon_social",
                    }],
                    pickListWidth: 260,
                    completeOnTab: true,
                    // Solo es pasado al servidor si no existe cache data all en el modelo
                    // de lo contrario el sort se hace en el lado cliente.
                    initialSort: [{property: 'empresa_razon_social'}],
                    startRow: true
                },
                {name: "usuarios_admin", defaultValue: false, showPending: true, endRow: true},
                {name: "activo", defaultValue: true, showPending: true, endRow: true}
            ]
                    //  disableValidation: true
        });
    },
    canShowTheDetailGridAfterAdd: function () {
        return true;
    },
    createDetailGridContainer: function (mode) {
        return isc.DetailGridContainer.create({
            width: 500,
            height: 150,
            sectionTitle: 'Asignar Perfiles',
            gridProperties: {
                dataSource: 'mdl_usuario_perfil',
                fetchOperation: 'fetchFull',
                autoFetchData: false,
                fields: [
                    {name: "sys_systemcode", title: 'Sistema', editorType: "comboBoxExt",
                        valueField: "sys_systemcode", displayField: "sistema_descripcion",
                        optionDataSource: mdl_sistemas, // TODO: podria ser tipo basic para no relleer , ver despues
                        pickListFields: [{name: "sys_systemcode", width: '25%'}, {name: "sistema_descripcion", title: 'Descripcion', width: '75%'}],
                        pickListWidth: 260,
                        completeOnTab: true,
                        width: '45%',
                        // Si hay cambios limpiamos el campo de perfil ya que los perfiles estan asociados a sistema
                        changed: function (form, item, value) {
                            this.grid.setEditValue(this.rowNum, 1, null);
                        }
                    },
                    {name: "perfil_id", editorType: "comboBoxExt",
                        valueField: "perfil_id", displayField: "perfil_descripcion",
                        optionDataSource: mdl_perfil, // TODO: podria ser tipo basic para no relleer , ver despues
                        pickListFields: [{name: "perfil_codigo", width: '20%'}, {name: "perfil_descripcion", width: '80%'}],
                        completeOnTab: true,
                        width: '45%',
                        editorProperties: {
                            getPickListFilterCriteria: function () {
                                var systemcode = this.grid.getEditedCell(this.rowNum, "sys_systemcode");
                                return {sys_systemcode: systemcode};
                            }
                        }
                    },
                    {name: "activo", width: '10%', canToggle: false}
                ],
                /**
                 * Luego de grabar se actualiza el caampo virtual del codigo del sistema ya que este en realidad no es
                 * parte del registro de la relacion perfil-usuario
                 */
                editComplete: function (rowNum, colNum, newValues, oldValues, editCompletionEvent, dsResponse) {
                    if (oldValues) {
                        if (oldValues.sys_systemcode != newValues.sys_systemcode && newValues.sys_systemcode) {
                            dsResponse.data[0].sys_systemcode = newValues.sys_systemcode;

                        } else {
                            dsResponse.data[0].sys_systemcode = oldValues.sys_systemcode;
                        }
                    } else {
                        dsResponse.data[0].sys_systemcode = newValues.sys_systemcode;
                    }
                }
            }});
    },
    initWidget: function () {
        this.Super("initWidget", arguments);
    }
});