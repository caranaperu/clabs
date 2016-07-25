<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones directas de los items de las ligas
 * que las relacionan con sus clubes asociados.
 *  tales como listar , agregar , eliminar , etc.
 *
 * @author $Author: aranape $
 * @since 17-May-2013
 * @version $Id: LigasClubesBussinessService.php 67 2014-03-09 10:17:54Z aranape $
 * @history 1.01 , Se agrego soporte para foreign key
 *
 * $Date: 2014-03-09 05:17:54 -0500 (dom, 09 mar 2014) $
 * $Rev: 67 $
 */
class LigasClubesBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("LigasClubesDAO", "ligasclubes", "msg_ligasclubes");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return LigasClubesModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new LigasClubesModel();
        // Leo el id enviado en el DTO
        $model->set_ligas_codigo($dto->getParameterValue('ligas_codigo'));
        $model->set_clubes_codigo($dto->getParameterValue('clubes_codigo'));
        $model->set_ligasclubes_desde($dto->getParameterValue('ligasclubes_desde'));
        $model->set_ligasclubes_hasta($dto->getParameterValue('ligasclubes_hasta'));
        if ($dto->getParameterValue('activo') !== NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->setUsuario($dto->getSessionUser());

        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return LigasClubesModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new LigasClubesModel();
        // Leo el id enviado en el DTO
        $model->set_ligasclubes_id($dto->getParameterValue('ligasclubes_id'));
        $model->set_ligas_codigo($dto->getParameterValue('ligas_codigo'));
        $model->set_clubes_codigo($dto->getParameterValue('clubes_codigo'));
        $model->set_ligasclubes_desde($dto->getParameterValue('ligasclubes_desde'));
        $model->set_ligasclubes_hasta($dto->getParameterValue('ligasclubes_hasta'));

        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') !== NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return LigasClubesModel
     */
    protected function &getEmptyModel() {
        $model = new LigasClubesModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new LigasClubesModel();
        $model->set_ligasclubes_id($dto->getParameterValue('ligasclubes_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());

        return $model;
    }

}

?>
