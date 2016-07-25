<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Description of execLoginController
 *
 * @author carana
 */
abstract class TSLBaseController extends CI_Controller {

    /**
     * El Data transfer Object
     * @var TSLIDataTransferObj
     */
    protected $DTO;

    /**
     * Dado que durante las rutinas de eror se cambian los working directories
     * se requiere una instancia del encoder de salida para los casos de error.
     * @var un encoder de salida
     */
    protected $responseProcessor;

    /**
     * Si envia mensajes de debug o no.
     * @var boolean
     */
    private $DEBUG = false;

    public function __construct() {
        parent::__construct();
        // Inicializa el Data Transfer Object
        $this->DTO = new TSLDataTransferObj();
        // Dado el contexto de las funciones de error las clases deben estar cargadas.
        $this->DTO->getOutMessage();
        $this->responseProcessor = $this->getResponseProcessor();

        // Se modifica los defaults de manejo de errores
        // para poder manejar mejor la salida de los mismo.
        //error_reporting(E_ALL ^ E_WARNING);
        // Esto se setea el¡n el main de la aplicacion (ejemplo muniren_admin.php)
//       error_reporting(E_ALL & ~E_DEPRECATED);

        ini_set('display_errors', 0);
        // Se apuntan los manejadores de errores y excepciones a los
        // contenidos en esta clase.
        @register_shutdown_function(array($this, 'MyShutdown'));
 //       @set_error_handler(array($this, 'myErrorHandler'));
        @set_exception_handler(array($this, 'MyExceptionHandler',));
    }

    public function MyShutdown() {
        $isError = false;
        if ($error = error_get_last()) {
            switch ($error['type']) {
                case E_ERROR:
                case E_CORE_ERROR:
                case E_COMPILE_ERROR:
                case E_USER_ERROR:
                case E_RECOVERABLE_ERROR:
                case E_NOTICE:
                case E_DEPRECATED:
                    $isError = true;
            }
        }

        if ($isError) {
            if ($this->DEBUG) {
                echo "Script fue detenido ({$error['message']})";
            }

            $outMessage = &$this->DTO->getOutMessage();
            $outMessage->setSuccess(false);
            $outMessage->setAnswerMessage('Error : ' . $error['message'], -10000);

            //   $data['data'] = $this->DTO;
          //  echo $this->responseProcessor->encode($this->DTO);

            // Parche para cerrar lo pendiente de codeigniter , por este camino se finaliza
            // abruptamente. NO EJECUTA HOOKS
            // TODO : Manejar los hooks.
            $CI = &get_instance();
            $OUT = & load_class('Output', 'core');

            $OUT->_display($this->responseProcessor->process($this->DTO));
            if (class_exists('CI_DB') AND isset($CI->db)) {
                $CI->db->close();
            }
        } else {
            if ($this->DEBUG) {
                echo "Script completado correctamente";
            }
        }
    }

    public function myErrorHandler($errno, $errstr, $errfile, $errline) {
        switch ($errno) {
            case E_NOTICE:
            case E_USER_NOTICE:
                $errors = "Notice";
                break;
            case E_WARNING:
            case E_USER_WARNING:
                $errors = "Warning";
                break;
            case E_ERROR:
            case E_USER_ERROR:
                $errors = "Fatal Error";
                break;
            default:
                $errors = "Unknown";
                break;
        }

        if (ini_get("display_errors")) {
            printf("<br />\n<b>%s</b>: %s in <b>%s</b> on line <b>%d</b><br /><br />\n", $errors, $errstr, $errfile, $errline);
        }

        if (ini_get('log_errors')) {
            error_log(sprintf("PHP %s:  %s in %s on line %d", $errors, $errstr, $errfile, $errline));
        }
        //printf("<br />\n<b>%s</b>: %s in <b>%s</b> on line <b>%d</b><br /><br />\n", $errors, $errstr, $errfile, $errline);
        //   exit();

        $outMessage = &$this->DTO->getOutMessage();
        // Solo se apendea error si no hay mensaje previo
        $outMessage->setSuccess(false);
        $outMessage->setAnswerMessage($errors . ' : ' . $errstr . ' Archivo : ' . $errfile . ' Linea :' . $errline, -10000);

        // $data['data'] = $this->DTO;
        echo $this->responseProcessor->process($this->DTO);

        // Parche para cerrar lo pendiente de codeigniter , por este camino se finaliza
        // abruptamente. NO EJECUTA HOOKS
        //
        // TODO : Manejar los hooks.
        $CI = &get_instance();
        $OUT = & load_class('Output', 'core');
        $OUT->_display();
        if (class_exists('CI_DB') AND isset($CI->db)) {
            $CI->db->close();
        }

        // Adios , nada mas que hacer.
        exit();

        //$this->load->view($this->getView(), $data);
    }

    public function MyExceptionHandler($exception) {
        echo "Uncaught exception: ", $exception->getMessage(), "\n";
    }

    /**
     * Reemplaza el valor de un parametro por el enviado en
     * el caso se cumpla la condicion de igualdad con el valueToSearch.
     * Util por ejemplo si el lado cliente envia el string 'null' para indicar
     * campo vacio  y deseamos reemplazarlo por ejemplo con un NULL
     * real.
     *
     * @param string $parameterName
     * @param mixed $valueToSearch
     * @param mixed $valueToReplace
     */
    protected function fixParameter($parameterName,$valueToSearch,$valueToReplace) {
        if (array_key_exists ($parameterName , $_POST)) {
            if ($_POST[$parameterName] === $valueToSearch) {
                $_POST[$parameterName] = $valueToReplace;
            }
            return $_POST[$parameterName];
        }
        return NULL;
    }

    protected final function validateInputData(TSLIDataTransferObj $DTO, $langId, $validationId, $validationGroupId, $validationRulesId) {

        // IMPORTANTE , solo funciona si hay POST data!!!!

        $this->lang->load($langId);

        // Load validations rules from an own validation file
        $this->load->config('validation/' . $validationId);
        $rules = $this->config->item($validationGroupId);

        // cargamos la libreria de validacion
        $this->load->library('form_validation');

        // Ejecutar validacion.
        $this->form_validation->set_error_delimiters('', '');
        $this->form_validation->set_rules($rules[$validationRulesId]);

        // Si hay errores se agregan al DTO
        if ($this->form_validation->run() === FALSE) {
            $outMsg = $DTO->getOutMessage();

            $flderrs = $rules[$validationRulesId];
            $count = count($flderrs);

            for ($i = 0; $i < $count; $i++) {
                $currentErrorMsg = $this->form_validation->error($flderrs[$i]['field']);

                // Solo agregamos el error si existe un mensaje de error
                if (isset($currentErrorMsg) && strlen($currentErrorMsg) > 0) {
                    // Crea el error de campo y lo agrega al mensaje de salida.
                    $fldError = new TSLFieldErrorMessage($flderrs[$i]['field'], $this->form_validation->error($flderrs[$i]['field']));
                    $outMsg->addFieldError($fldError);
                    unset($fldError);
                }
                unset($currentErrorMsg);
            }
            unset($flderrs);
            return FALSE;
        }
        return TRUE;
    }

    /**
     * Deber retorna la vista de salida
     */
    abstract protected function getView();

    /*
     * Deber retorna la el procesador de la respuesta
     */
    abstract protected function getResponseProcessor();

    /**
     * Override si se usa un response especifico en algun caso.
     *
     * @return string con el nombre del procesador de salida definida
     * por el usuario , de ser null se aplicara los metodos default de carga
     * de dichas clases ver TSLResponseProcessorLoaderHelper
     */
    protected function getUserResponseProcessor() {
        return NULL;
    }
}