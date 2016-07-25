<?php

/**
 * Clase que define el mensaje de salida el cul sera armado o recopilado
 * a traves del data transfer object .
 *
 * @author Carlos Arana Reategui
 * @version 1.00 , 27 MAY 2011
 *
 * @since 1.00
 *
 */
class TSLOutMessage {

    /**
     * Arreglo con los errores de proceso.
     *
     * @var array m_processErrors
     */
    private $m_processErrors;

    /**
     * Arreglo con los errores de validacion
     * de campos o parametros..
     *
     * @var array m_fieldErrors
     */
    private $m_fieldErrors;

    /**
     * True indicara que el mensaje contiene solo data de salida,
     * no errores.
     * @var boolean $m_success
     */
    private $m_success = true;

    /**
     * Opcional para enviar un mensaje de respuesta.
     * @var string $m_answerMessage
     */
    private $m_answerMessage;

    /**
     * Codigo de identificacion en caso que $m_answerMessage
     * sea un mensaje de error.
     * @var int $m_errorCode
     */
    private $m_errorCode = 0;

    /**
     * Contendra los datos de salida.
     * @var object $m_answerMessage
     */
    private $m_resultData;

    /**
     * Contendra un arreglo de datos extras si fuera necesario
     * tales como numero de registros, ultimo registro , o lo que se requiera.
     * .
     * @var object $m_outParams
     */
    private $m_outParams;


    /**
     * Setea si este mensaje de salida es de error o no , si el parametro
     * es false , se considerara como error.
     * @param int $success true si no hay error de lo contrario false
     */
    public function setSuccess($success) {
        if (is_bool($success) === true) {
            $this->m_success = $success;
        } else {
            $this->m_success = false;
        }
    }

    /**
     * Agrega un error de proceso
     *
     * @param TSLProcessErrorMessage $processError un error de proceso
     */
    public function addProcessError(TSLProcessErrorMessage $processError){
        if (isset ($processError)) {
            // Si hay error ya no es success
            $this->setSuccess(false);
            $this->m_processErrors[] = $processError;
        }
    }

    /**
     * Agrega un error de campo , bascamente provienen de erores en la validacion previa
     * de campos o parametros.
     *
     * @param TSLFieldErrorMessage $fieldError un error de campo o parametro
     */
    public function addFieldError(TSLFieldErrorMessage $fieldError){
        if (isset ($fieldError)) {
            // Si hay error ya no es success
            $this->setSuccess(false);
            $this->m_fieldErrors[] = $fieldError;
        }
    }

    /**
     * Agrega un prametro al arreglo de parametros de salida.
     *
     * @param string $paramName nombre de parametro.
     * @param mixed $paramValue  valor del parametor
     */
    public function addOutputParameter($paramName,$paramValue) {
        $this->m_outParams[$paramName] = $paramValue;
    }

    /**
     * Retorna el arreglo de parametros de salida si es que existen.
     */
    public function &getOutputparameters() {
        return $this->m_outParams;
    }

    /**
     * Cuando se realiza una operacion correcta , los datos
     * de respuesta deberan ser indicados a raves de este metodo,
     * los datos contenidos seran interpretados por contexto por
     * la fncion que espera los resultados.
     *
     * @param Object $resultData los datos resultado.
     */
    public function setResultData(&$resultData) {
        if (isset ($resultData)) {
            $this->m_resultData = $resultData;
        }
    }

    /**
     * Retorna los datos resultado.
     * @return Object con los resultados.
     */
    public function &getResultData() {
        return $this->m_resultData;
    }

    /**
     * Si se requiriera enviar un mensaje en caso de un error que no es
     * de proceso o validaion de modelo o un mensaje de salida comoe
     * "Operacion Realizada con exito" dicho mensaje podria ser
     * colocado aqui , asi mismo si el eror proviniera de una excepcion
     * o requiriera un codigo especial (SQL ERROR CODE por ejemplo) podria
     * inidicarse en el segundo pramtero.
     *
     * @param string $errorMessage el mensaje de salida
     * @param int codigo de error.
     */
    public function setAnswerMessage($errorMessage,$errorCode) {
        if (isset ($errorMessage)) {
            // Cambio comillas por coma simple ya que en json o xml ocasionan problemas
            $this->m_answerMessage =str_replace(array("\"","\r","\n","\r\n"), ' ',$errorMessage);
            $this->m_errorCode = $errorCode;
        }
    }

    /**
     * Retorna el mensaje de salida.
     * @return String con el mensaje de salida.
     */
    public function getAnswerMesage() {
        if (isset($this->m_answerMessage) && empty($this->m_answerMessage) == FALSE)
            return $this->m_answerMessage;
        else
            return '';
    }

    /**
     * Retorna el codigo de error global.
     * @return int con el codigo de error
     */
    public function getErrorCode() {
        return $this->m_errorCode;
    }

    /**
     * Retorna los errores de proceso.
     *
     * @return array con los mensajes de procesos.
     */
    public function &getProcessErrors() {
        return $this->m_processErrors;
    }

    /**
     * Retorna la lista de mensajes de error de validacion de campos
     * o parametros.
     * @return array con los mensajes de error de campo o parametros
     */
    public function &getFieldErrors() {
        return $this->m_fieldErrors;
    }

    /**
     * Retorna si tiene o no tiene mensajes de error de proceso
     * esta instancia.
     *
     * @return boolean true tiene mensajes de proceso, false no.
     */
    public function hasProcessErrors() {
        if (isset($this->m_processErrors) && count($this->m_processErrors) > 0) {
            return true;
        }
        return false;
    }

    /**
     * Retorna si tiene o no tiene mensajes de error de campos
     * esta instancia.
     *
     * @return boolean true tiene mensajes de campos, false no.
     */
    public function hasFieldErrors() {
        if (isset($this->m_fieldErrors) && count($this->m_fieldErrors) > 0) {
            return true;
        }
        return false;
    }

    /**
     * Retorna si el resultado de la operacion fue correcta.
     *
     * @return boolean true si fue exitosa , false si hubo
     * errores.
     */
    public function isSuccess() {
        return $this->m_success;
    }

}

?>