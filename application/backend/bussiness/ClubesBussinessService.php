<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los clubes a asociarse
 * a las ligas, tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: ClubesBussinessService.php 43 2014-02-18 16:32:15Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-02-18 11:32:15 -0500 (mar, 18 feb 2014) $
 * $Rev: 43 $
 */
class ClubesBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("ClubesDAO", "clubes", "msg_clubes");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return ClubesModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new ClubesModel();
        // Leo el id enviado en el DTO
        $model->set_clubes_codigo($dto->getParameterValue('clubes_codigo'));
        $model->set_clubes_descripcion($dto->getParameterValue('clubes_descripcion'));
        $model->set_clubes_persona_contacto($dto->getParameterValue('clubes_persona_contacto'));
        $model->set_clubes_direccion($dto->getParameterValue('clubes_direccion'));
        $model->set_clubes_email($dto->getParameterValue('clubes_email'));
        $model->set_clubes_telefono_oficina($dto->getParameterValue('clubes_telefono_oficina'));
        $model->set_clubes_telefono_celular($dto->getParameterValue('clubes_telefono_celular'));
        $model->set_clubes_web_url($dto->getParameterValue('clubes_web_url'));

        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return ClubesModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new ClubesModel();
        // Leo el id enviado en el DTO
        $model->set_clubes_codigo($dto->getParameterValue('clubes_codigo'));
        $model->set_clubes_descripcion($dto->getParameterValue('clubes_descripcion'));
        $model->set_clubes_persona_contacto($dto->getParameterValue('clubes_persona_contacto'));
        $model->set_clubes_direccion($dto->getParameterValue('clubes_direccion'));
        $model->set_clubes_email($dto->getParameterValue('clubes_email'));
        $model->set_clubes_telefono_oficina($dto->getParameterValue('clubes_telefono_oficina'));
        $model->set_clubes_telefono_celular($dto->getParameterValue('clubes_telefono_celular'));
        $model->set_clubes_web_url($dto->getParameterValue('clubes_web_url'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return ClubesModel
     */
    protected function &getEmptyModel() {
        $model = new ClubesModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new ClubesModel();
        $model->set_clubes_codigo($dto->getParameterValue('clubes_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
