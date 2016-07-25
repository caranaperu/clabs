<?php

//require_once (APPPATH . '../framework/techsoft/fw/dto/TSLIDataTransferObj.php');

/**
 * Implementacion del Data Transfero Object a ser usado
 * por el sistema.
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 7 JUN 2011
 *
 * @since 1.00
 *
 */
class TSLDataTransferObj implements \TSLIDataTransferObj {

    /**
     * La lista de modelos a usar,
     * @var array TSLDataModel $m_Models
     */
    private $m_Models = null;

    /**
     * Contiene el mensaje de salida..
     *
     * @var TSLOutMessage $m_OutMessage
     */
    private $m_OutMessage = null;

    /**
     * Contiene los constraints de paginacion si se requirieran
     *
     * @var TLSDbConstraints
     */
    private $m_Constraints = null;

    /**
     * El usuario de la session
     *
     * @var string
     */
    private $m_sessionUser = null;

    /**
     * Se agrega un model el cual sera usado para el proceso del bussiness
     * object.
     *
     * @param string $modelId el identificador unico del modelo a usar
     * @param TSLDataModel $model  lainstancia del modelo
     */
    public function addModel($modelId, TSLDataModel &$model) {
        if (isset($modelId)) {
            $this->m_Models[$modelId] = $model;
        }
    }

    /**
     * Retorna la instancia de modelo basado en el id enviado,
     * de no existir retorna un objeto indefinido.
     *
     * @param string $modelId con el identificador unico de un modelo de trabajo.
     * @return TSLDataModel la instancia del modelo.
     */
    public function &getModel($modelId) {
        // Retorna el modelo asociado al model Id , null
        // si no existe.
        return $this->m_Models[$modelId];
    }

    /**
     *
     * @see TSLIDataTransferObj
     */
    public function addParameter($parameterId, $parameterData) {
        if (isset($parameterId)) {
            $this->m_parameters[$parameterId] = $parameterData;
        }
    }

    /**
     *
     * @see TSLIDataTransferObj
     */
    public function getParameterValue($parameterId) {
        if (isset($this->m_parameters[$parameterId]))
            return $this->m_parameters[$parameterId];
        else
            return NULL;
    }

    /**
     * Retorna la instancia del objeto de salida.
     * @return TSLOutMessage la intancia del mensaje de salida.
     *
     * @see TSLIDataTransferObj
     */
    public function &getOutMessage() {
        // Si no esta creado lo creamos y retornamos el nuevo objeto,
        // de lo contrario retornamos la instancia existente.
        if (!isset($this->m_OutMessage) || is_null($this->m_OutMessage)) {
            $this->m_OutMessage = new TSLOutMessage();
            // Por default en false
            $this->m_OutMessage->setSuccess(false);
        }
        return $this->m_OutMessage;
    }

    /**
     *
     * Retorna la instancia de los constraints par ser setreada.
     * @return TSLRequestConstraints la intancia delos constraints.
     *
     * @see TSLRequestConstraints
     */
    public function &getConstraints() {
        // Si no esta creado lo creamos y retornamos el nuevo objeto,
        // de lo contrario retornamos la instancia existente.
        if (!isset($this->m_Constraints) || is_null($this->m_Constraints))
            $this->m_Constraints = new TSLRequestConstraints ();
        return $this->m_Constraints;
    }

    /**
     * @see TSLIDataTransferObj
     */
    public function setOperation($operation) {
        $this->addParameter("operation", $operation);
    }

    /**
     * @see TSLIDataTransferObj
     */
    public function getOperation() {
        return $this->getParameterValue("operation");
    }

    /**
     *
     * @return string con el usuario de la sesion
     */
    public function getSessionUser() {
        return $this->m_sessionUser;
    }

    /**
     * Retorna el nombre del usuario de la sesion.
     *
     * @param string $m_sessionUser
     */
    public function setSessionUser($m_sessionUser) {
        $this->m_sessionUser = $m_sessionUser;
    }

    /**
     * @see TSLIDataTransferObj
     */
    public function setSubOperationId($suboperation) {
        $this->addParameter("suboperation", $suboperation);
    }

    /**
     * @see TSLIDataTransferObj
     */
    public function getSubOperation() {
        return $this->getParameterValue("suboperation");
    }

}

?>