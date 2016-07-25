<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Clase abstracta que debera implementarse para los controladores de los reportes
 * del sistema.
 *
 * @author $Author: aranape $
 * @since 17-May-2012
 * @version $Id: TSLReportController.php 4 2014-02-11 03:31:42Z aranape $
 *
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 * $Rev: 4 $
 */
abstract class TSLReportController extends CI_Controller {

    public function __construct() {
        parent::__construct();
    }

    /**
     * Retorna el prefijo para el nombre de los parametros, por default
     * es PARAM_.
     *
     * @return string con el prefijo para el nombre de los parametros
     */
    public function getReportParameterPrefix() {
        return 'PARAM_';
    }

    /**
     * Devolvera un arreglo de parametros para el reporte, procesados
     * ya para el reporteador , se ha elegido que los parametros
     * seran antecedidos por el valor devuelto  getReportParameterPrefix().
     * Se entiende que al crear el reporte en el backend digase Crystal Reports,
     * JasperReports y otros estos deberan crearse tomando en cuenta la nomnecatura
     * de parametros indcado por el prefijo elegido y el nombre del campo
     * PREFIX_nombrecampo.
     *
     * @param array  $reportParamNames Lista de los nombres de los parametros
     * esperados.
     *
     * @return array con los parametros del reporte ya procesados al formato PREFIX_nombrecampo
     *
     */
    protected function &getReportParams(array $reportParamNames) {
        $prefix = $this->getReportParameterPrefix();
        $report_params = array();

        if (is_array($reportParamNames)) {
            foreach ($reportParamNames as $str) {
                $report_params[$prefix . $str] = '';
                // Parche de parametros
                foreach ($_POST as $i => $value) {
                    // Comienza con?
                    if (strpos($i, $str, 0) === 0) {
                        $report_params[$prefix . $i] = $value;
                    }
                }
            }
        } else {
            // Parche de parametros
            foreach ($_POST as $i => $value) {
                $report_params[$prefix . $reportParamNames] = '';
                // Comienza con?
                if (strpos($i, $reportParamNames, 0) === 0) {
                    $report_params[$prefix . $i] = $value;
                }
            }
        }
        return $report_params;
    }

    /**
     * Retorna un string con la direccion URI que accesa
     * al reporte en el servidor.
     *
     * @return string El URI del reporte.
     */
    abstract protected function getReportURI();

    /**
     * Retorna el directorio donde se guardaran los reportes generados
     * para su posterior download desde el cleinte.
     *
     * @return string con el directorio a guardar la salida final
     */
    abstract protected function getTmpOutputDirectory();

    /**
     * Dado el contenido final , este metodo debera grabar y devolver si no ha habido
     * problemas el filename del archivo del reporte o FALSE si hubo error.
     *
     * @param mixed $contents contenido de salida  del reporte a grabar.
     * @return mixed El filename si fue creado correctamente o FALSE si hubo errores
     */
    abstract protected function createReportOutputFile(&$contents);

    /**
     * Punto de entrada de ejecucion de los reportes, rutina principal que debe generar y procesar
     * el reporte en el backend y ponerlo disponible al cliente.
     *
     * @param string $reportServerUser usuario del reporteador.
     * @param string $reportServerPassword password del usuario del reporteador.
     * @param string $formatOutput formato de salida (PDF,XLS,HTML).
     */
    abstract protected function executeReport($reportServerUser, $reportServerPassword, $formatOutput);
}

?>
