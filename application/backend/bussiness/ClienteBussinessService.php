<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Objeto de Negocios que manipula las acciones a los datos
 * de los clientes..
 *
 * @author $Author: aranape $
 * @version $Id: EmpresaBussinessService.php 7 2014-02-11 23:55:54Z aranape $
 * @since 17-May-2013
 *
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 * $Rev: 7 $
 */
class ClienteBussinessService extends \app\common\bussiness\TSLAppCRUDBussinessService {

    function __construct() {
        //    parent::__construct();
        $this->setup("ClienteDAO", "cliente", "msg_cliente");
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return ClienteModel
     */
    protected function &getModelToAdd(\TSLIDataTransferObj $dto) {
        $model = new ClienteModel();
        // Leo el id enviado en el DTO
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_cliente_razon_social($dto->getParameterValue('cliente_razon_social'));
        $model->set_tipo_cliente_codigo($dto->getParameterValue('tipo_cliente_codigo'));
        $model->set_cliente_ruc($dto->getParameterValue('cliente_ruc'));
        $model->set_cliente_direccion($dto->getParameterValue('cliente_direccion'));
        $model->set_cliente_telefonos($dto->getParameterValue('cliente_telefonos'));
        $model->set_cliente_fax($dto->getParameterValue('cliente_fax'));
        $model->set_cliente_correo($dto->getParameterValue('cliente_correo'));

        // En el caso de agregar una entidad siempre ira en true
        $model->setActivo(TRUE);
        $model->setUsuario($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return ClienteModel
     */
    protected function &getModelToUpdate(\TSLIDataTransferObj $dto) {
        $model = new ClienteModel();
        // Leo el id enviado en el DTO
        $model->set_cliente_id($dto->getParameterValue('cliente_id'));
        $model->set_empresa_id($dto->getParameterValue('empresa_id'));
        $model->set_cliente_razon_social($dto->getParameterValue('cliente_razon_social'));
        $model->set_tipo_cliente_codigo($dto->getParameterValue('tipo_cliente_codigo'));
        $model->set_cliente_ruc($dto->getParameterValue('cliente_ruc'));
        $model->set_cliente_direccion($dto->getParameterValue('cliente_direccion'));
        $model->set_cliente_telefonos($dto->getParameterValue('cliente_telefonos'));
        $model->set_cliente_fax($dto->getParameterValue('cliente_fax'));
        $model->set_cliente_correo($dto->getParameterValue('cliente_correo'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        if ($dto->getParameterValue('activo') != NULL)
            $model->setActivo($dto->getParameterValue('activo'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

    /**
     *
     * @return ClienteModel
     */
    protected function &getEmptyModel() {
        $model = new ClienteModel();
        return $model;
    }

    /**
     *
     * @param \TSLIDataTransferObj $dto
     * @return \TSLDataModel
     */
    protected function &getModelToDelete(\TSLIDataTransferObj $dto) {
        $model = new ClienteModel();
        $model->set_cliente_id($dto->getParameterValue('cliente_id'));
        $model->setVersionId($dto->getParameterValue('versionId'));
        $model->set_Usuario_mod($dto->getSessionUser());
        return $model;
    }

}

?>
