<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas a las operaciones a los usuarios
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape@gmail.com $
 * @since 17-May-2013
 * @version $Id: UsuariosBussinessService.php 57 2015-08-23 22:46:22Z aranape@gmail.com $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2015-08-23 17:46:22 -0500 (dom, 23 ago 2015) $
 * $Rev: 57 $
 */
class UsuariosBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("UsuariosDAO", "usuarios", "msg_usuarios");
    }

    /**
     * NO usada
     * @param \TSLIDataTransferObj $dto
     * @return UsuariosModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new UsuariosModel();
        $model->set_usuarios_code($dto->getParameterValue('usuarios_code'));
        $model->set_usuarios_password($dto->getParameterValue('usuarios_password'));
        $model->set_usuarios_nombre_completo($dto->getParameterValue('usuarios_nombre_completo'));
        $model->set_usuarios_admin($dto->getParameterValue('usuarios_admin'));

        if ($dto->getParameterValue('activo') != NULL) {
            $model->setActivo($dto->getParameterValue('activo'));
        } else {
            $model->setActivo(FALSE);
        }
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     * NO USADA
     * @param \TSLIDataTransferObj $dto
     * @return UsuariosModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new UsuariosModel();

        $model->set_usuarios_id($dto->getParameterValue('usuarios_id'));
        $model->set_usuarios_code($dto->getParameterValue('usuarios_code'));
        $model->set_usuarios_password($dto->getParameterValue('usuarios_password'));
        $model->set_usuarios_nombre_completo($dto->getParameterValue('usuarios_nombre_completo'));
        $model->set_usuarios_admin($dto->getParameterValue('usuarios_admin'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL) {
            $model->setActivo($dto->getParameterValue('activo'));
        } else {
            $model->setActivo(FALSE);
        }
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @return UsuariosModel
     */
    protected function &getEmptyModel() {
        $model = new UsuariosModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new UsuariosModel();
        $model->set_usuarios_id($dto->getParameterValue('usuarios_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}

?>
