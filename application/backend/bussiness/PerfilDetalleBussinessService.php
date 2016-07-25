<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula la entidad asignacion de personal.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: PerfilDetalleBussinessService.php 402 2014-01-11 09:28:24Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-01-11 04:28:24 -0500 (sáb, 11 ene 2014) $
 * $Rev: 402 $
 */
class PerfilDetalleBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //parent::__construct();
        $this->setup("app\\common\\dao\\impl\\TSLAppPerfilDetalleDAO", "perfildetalle", "msg_perfildetalle");
    }

    /**
     *
     * @return \app\common\model\impl\TSLAppPerfilDetalleModel()
     */
    protected function &getEmptyModel() {
        $model = new \app\common\model\impl\TSLAppPerfilDetalleModel();
        return $model;
    }

    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new \app\common\model\impl\TSLAppPerfilDetalleModel();

        $model->set_perfil_id($dto->getParameterValue('perfil_id'));
        $model->set_perfdet_accessdef($dto->getParameterValue('perfdet_accessdef'));
        $model->set_perfdet_accagregar($dto->getParameterValue('perfdet_accagregar'));
        $model->set_perfdet_accactualizar($dto->getParameterValue('perfdet_accactualizar'));
        $model->set_perfdet_accleer($dto->getParameterValue('perfdet_accleer'));
        $model->set_perfdet_acceliminar($dto->getParameterValue('perfdet_acceliminar'));
        $model->set_perfdet_accimprimir($dto->getParameterValue('perfdet_accimprimir'));

        $model->set_menu_id($dto->getParameterValue('menu_id'));

        if ($dto->getParameterValue('activo') != NULL) {
            $model->setActivo($dto->getParameterValue('activo'));
        }
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new \app\common\model\impl\TSLAppPerfilDetalleModel();
        $model->set_perfdet_id($dto->getParameterValue('perfdet_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new \app\common\model\impl\TSLAppPerfilDetalleModel();

        $model->set_perfdet_id($dto->getParameterValue('perfdet_id'));
        $model->set_perfil_id($dto->getParameterValue('perfil_id'));
        $model->set_perfdet_accessdef($dto->getParameterValue('perfdet_accessdef'));
        $model->set_perfdet_accagregar($dto->getParameterValue('perfdet_accagregar'));
        $model->set_perfdet_accactualizar($dto->getParameterValue('perfdet_accactualizar'));
        $model->set_perfdet_accleer($dto->getParameterValue('perfdet_accleer'));
        $model->set_perfdet_acceliminar($dto->getParameterValue('perfdet_acceliminar'));
        $model->set_perfdet_accimprimir($dto->getParameterValue('perfdet_accimprimir'));

        $model->set_menu_id($dto->getParameterValue('menu_id'));

        if ($dto->getParameterValue('activo') != NULL) {
            $model->setActivo($dto->getParameterValue('activo'));
        }
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}

?>
