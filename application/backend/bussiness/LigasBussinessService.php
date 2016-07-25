<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas las ligas federadas
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: LigasBussinessService.php 44 2014-02-18 16:33:05Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-02-18 11:33:05 -0500 (mar, 18 feb 2014) $
 * $Rev: 44 $
 */
class LigasBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("LigasDAO", "ligas", "msg_ligas");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return LigasModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new LigasModel();
        // Leo el id enviado en el DTO
        $model->set_ligas_codigo($dto->getParameterValue('ligas_codigo'));
        $model->set_ligas_descripcion($dto->getParameterValue('ligas_descripcion'));
        $model->set_ligas_persona_contacto($dto->getParameterValue('ligas_persona_contacto'));
        $model->set_ligas_direccion($dto->getParameterValue('ligas_direccion'));
        $model->set_ligas_email($dto->getParameterValue('ligas_email'));
        $model->set_ligas_telefono_oficina($dto->getParameterValue('ligas_telefono_oficina'));
        $model->set_ligas_telefono_celular($dto->getParameterValue('ligas_telefono_celular'));
        $model->set_ligas_web_url($dto->getParameterValue('ligas_web_url'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return LigasModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new LigasModel();
        // Leo el id enviado en el DTO
        $model->set_ligas_codigo($dto->getParameterValue('ligas_codigo'));
        $model->set_ligas_descripcion($dto->getParameterValue('ligas_descripcion'));
        $model->set_ligas_direccion($dto->getParameterValue('ligas_direccion'));
        $model->set_ligas_persona_contacto($dto->getParameterValue('ligas_persona_contacto'));
        $model->set_ligas_email($dto->getParameterValue('ligas_email'));
        $model->set_ligas_telefono_oficina($dto->getParameterValue('ligas_telefono_oficina'));
        $model->set_ligas_telefono_celular($dto->getParameterValue('ligas_telefono_celular'));
        $model->set_ligas_web_url($dto->getParameterValue('ligas_web_url'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return LigasModel
     */
    protected function &getEmptyModel() {
        $model = new LigasModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new LigasModel();
        $model->set_ligas_codigo($dto->getParameterValue('ligas_codigo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
