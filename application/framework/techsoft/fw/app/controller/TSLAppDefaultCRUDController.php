<?php

namespace app\common\controller;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Controlador sugerido como default para las aplicaciones tipo CRUD las cuales
 * tiene operaciones de fetch,read,update y delete.
 *
 * Por default , todos los input parametros que sean pasados por parseParameters
 * seran procesados de tal forma que los 'null' se conviertan en reales NULL.
 *
 * Siempre usaran un unico via de salida el cual esta preparado para responder a
 * ajax calls.
 *
 * Los reponse y constraint processor seran cargados dinamicamente a partir de los parametros
 * libid (que libreria se esta usando) y filterformat (XML,json,etc)
 *
 * El setup se hace a traves del arreglo setupOpts y debe ser realizado en la funcion setupData llamada durante
 * la inicializacion de la clas.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2016
 * @version $Id: TSLAppDefaultCRUDController.php 193 2014-06-23 19:50:39Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:50:39 -0500 (lun, 23 jun 2014) $
 * $Rev: 193 $
 */
abstract class TSLAppDefaultCRUDController extends TSLAppDefaultController {

    /**
     * Los elementos son :
     * validateOptions
     * Arreglo con la lista de parametros requeridos para la validacion , su estructura debe ser siempre
     * [
     *      "operationName1"=>array("langId"=>'string', "validationId"=>'string', "validationGroupId"=>'string', "validationRulesId"=>'string'),
     *      "operationName2"=>array("langId"=>'string', "validationId"=>'string', "validationGroupId"=>'string', "validationRulesId"=>'string'),
     *      ......
     * ]
     *
     * paramsList
     * Arreglo con la lista de parametros que utilizara el controller y pasara al DTO para luego armar el modelo
     * requerido para la operacion.
     *
     * [
     *      "operationName1"=>array('field1','field2','field3',...),
     *      "operationName2"=>array('field1','field2','field3',...)
     *      ......
     * ]
     *
     * paramsFixableToNull
     * Arreglo con la lista de parametros o patron de lista de parametros que se verificaran si deben cambiarse de 'null' a NULL
     * Este arreglo puede contener un nombre parcial que identifique a un grupo de parametros , por ejemplo :
     * usuarios_  quiere decir todo parametro que empiece con usuarios_ tales como usuarios_id,usuarios_nombre, etc
     * o puede contener nombres exactos.
     *
     * [
     *      'usuarios_','atletas_',prueba_id',....
     * ]
     *
     * paramsFixableToValue
     * Arreglo con la lista de parametros que deben ser mapeados de valor.
     *
     * [
     *      array("name"=>"paramName1","valueToFix" => 'null', "valueToReplace" => NULL,"isID"=>true),
     *      array("name"=>"paramName2","valueToFix" => 'null', "valueToReplace" => '0')
     *      ......
     * ]
     *
     * paramToMapId
     * Define que parametro sera colocado como id para el caso de la lectura de un registro.
     * por ejemplo usuarios_id representa el id de busqueda , en este caso este sera colocado como el id
     * para buscar el registro a leer.
     *
     *
     * Ejemplo :
     *
     * $this->setupOpts =  [
     *            "validateOptions" => [
     *                  "operationName1"=>array("langId"=>'string', "validationId"=>'string', "validationGroupId"=>'string', "validationRulesId"=>'string'),
     *                  "operationName2"=>array("langId"=>'string', "validationId"=>'string', "validationGroupId"=>'string', "validationRulesId"=>'string')
     *            ],
     *            "paramsList" => [
     *                  array("name"=>"paramName1","valueToFix" => 'null', "valueToReplace" => NULL,"isID"=>true),
     *                  array("name"=>"paramName2","valueToFix" => 'null', "valueToReplace" => '0')
     *            ],
     *            "paramsFixableToNull" => ['usuarios_id'],
     *            "paramsFixableToValue" => ["usuarios_id" => ["valueToFix" => 'null', "valueToReplace" => NULL, "isID" => true]],
     *            "paramToMapId" => 'usuarios_id'
     *        ];
     *
     *
     *
     *
     *
     * $setupOpts debe ser inicializada durante el metodo setupData()
     * @var array
     */
    protected $setupOpts;

    public function __construct() {
        parent::__construct();
        $this->setupData();
    }

    abstract protected function getBussinessService();

    abstract protected function setupData();

    protected function preExecuteOperation($operationCode) {}

    private function executeCrudOperation($operationCode) {

        try {
            // Validamos
            $vopt = $this->setupOpts["validateOptions"][$operationCode];
            if (isset($vopt) && count($vopt) > 0) {
                $validateResult = $this->validateInputData($this->DTO, $vopt["langId"], $vopt["validationId"], $vopt["validationGroupId"], $vopt["validationRulesId"]);
            } else {
                // Si no requiere validacion indicamos ok.
                $validateResult = TRUE;
            }

            // Si todo esta ok procedemos
            if ($validateResult == TRUE) {

                // Algun procesamiento especial  antes de la operacion ?
                $this->preExecuteOperation($operationCode);

                // Pasamos parametros al DATA TRANSFER OBJECT
                $params = $this->setupOpts["paramsList"][$operationCode];
                if (isset($params) && count($params) > 0) {
                    foreach ($params as $param) {
                        $this->DTO->addParameter($param, $this->input->get_post($param));
                    }

                    // Para la operacion de lectura requerimos un id , aqui de acuerdo a lo indicado en
                    // la configuracion a traves de $paramToMapId ponemos el valor de ese campo como id.
                    if ($operationCode == 'read') {
                        if (isset($this->setupOpts["paramToMapId"])) {
                            $this->DTO->addParameter('id', $this->input->get_post($this->setupOpts["paramToMapId"]));
                        }
                    }
                }
                // Para la operacion fetch se requiere procesar los constraints  por si se requiere filtrar las respuestas
                if ($operationCode == 'fetch') {
                    $constraints = &$this->DTO->getConstraints();
                    // Procesamos los constraints
                    $this->getConstraintProcessor()->process($_REQUEST, $constraints);
                }
                // Ir al Bussiness Object
                //$service = $this->getBussinessService();
                $this->getBussinessService()->executeService($operationCode, $this->DTO);
            }
        } catch (\Exception $ex) {
            $outMessage = &$this->DTO->getOutMessage();
            // TODO: Internacionalizar.
            $processError = new TSLProcessErrorMessage($ex->getCode(), 'Error Interno', $ex);
            $outMessage->addProcessError($processError);
        }
    }

    /**
     * Pagina index para este controlador , maneja todos los casos , lectura, lista
     * etc.
     */
    public function index() {
        if ($this->isLoggedIn() == TRUE) {
            // Algunas librerias envia el texto null en casos de campos sin datos lo ponemos a NULL
            $paramsFixableToNull = $this->setupOpts["paramsFixableToNull"];
            if (isset($paramsFixableToNull) && count($paramsFixableToNull) > 0) {
                foreach ($paramsFixableToNull as $paramFixable) {
                    $this->parseParameters($paramFixable);
                }
            }
            // Si deberian existir parametros o algunos de sus valores deben ser mapeados a otros
            // procedemos a efectuar dicha accion
            $paramsFixableToValue = $this->setupOpts["paramsFixableToValue"];
            if (isset($paramsFixableToValue) && count($paramsFixableToValue) > 0) {
                foreach ($paramsFixableToValue as $paramToFix => $paramFixableToValue) {
                    if (isset($paramFixableToValue["isID"]) and $paramFixableToValue["isID"] == TRUE) {
                        $Id = $this->fixParameter($paramToFix, $paramFixableToValue["valueToFix"], $paramFixableToValue["valueToReplace"]);
                    } else {
                        $this->fixParameter($paramToFix, $paramFixableToValue["valueToFix"], $paramFixableToValue["valueToReplace"]);
                    }
                }
            }

            // Vemos si esta definido el tipo de suboperacion
            $operationId = $this->input->get_post('_operationId');
            if (isset($operationId) && is_string($operationId)) {
                $this->DTO->setSubOperationId($operationId);
            }


            // Se setea el usuario
            $this->DTO->setSessionUser($this->getUserCode());

            // Leera los datos del tipo de contribuyentes por default si no se envia
            // una operacion especifica.
            $op = $_REQUEST['op'];
            if (!isset($op) || $op == 'fetch') {
                // Si la suboperacion es read o no esta definida y se ha definido la pk se busca un registro unico
                // de lo contrario se busca en forma de resultset
                if (isset($Id) && ($operationId == 'read' || !isset($operationId) || $operationId === FALSE)) {
                    $this->DTO->setOperation(\TSLIDataTransferObj::OP_READ);
                    $this->executeCrudOperation('read');
                } else {
                    $this->DTO->setOperation(\TSLIDataTransferObj::OP_FETCH);
                    $this->executeCrudOperation('fetch');
                }
            } else {
                if ($op == 'upd') {
                    $this->DTO->setOperation(\TSLIDataTransferObj::OP_UPDATE);
                    $this->executeCrudOperation($op);
                } else {
                    if ($op == 'del') {
                        $this->DTO->setOperation(\TSLIDataTransferObj::OP_DELETE);
                        $this->executeCrudOperation($op);
                    } else {
                        if ($op == 'add') {
                            $this->DTO->setOperation(\ TSLIDataTransferObj::OP_ADD);
                            $this->executeCrudOperation($op);
                        } else {
                            $outMessage = &$this->DTO->getOutMessage();
                            // TODO: Internacionalizar.
                            $processError = new \TSLProcessErrorMessage(70000, 'Operacion No Conocida', null);
                            $outMessage->addProcessError($processError);
                        }
                    }
                }
            }
        } else {
            $outMessage = &$this->DTO->getOutMessage();
            // TODO: Internacionalizar.
            $processError = new \TSLProcessErrorMessage(70010, 'No se encuentra logeado al sistema', null);
            $outMessage->addProcessError($processError);
        }
        
        // Envia los resultados a traves del DTO
        //$this->responseProcessor->process($this->DTO);
        $data['data'] = &$this->responseProcessor->process($this->DTO);
        $this->load->view($this->getView(), $data);
    }

}
