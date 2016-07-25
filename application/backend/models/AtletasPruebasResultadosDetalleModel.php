<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir un mixto entre la tabla de competenciasPruebas y la de
 * atletasResultados , este requeriniento se debe unicamente a que el sistema necesita
 * un lugar donde se pueda grabar directamente resultados de los atletas
 * sin pasar por la competencia, creacion de prueba en la competencia y finalment
 * el resultado. La idea es que para el usuario sea transparente ingresar los datos directamente
 * al atleta (no se conoce nada sobre las pruebas de una competencia , solo la actuacion individual
 * del atleta) o via la pantalla de resultados de una prueba que pertenece a una competencia , ya que
 * en ese lugar solo se precisa grabar el resultado ya que la prueba debe estar previamente
 * creada.
 *
 * EN ESTE CASO ES PARA LAS PRUEBAS DETALLE DE UNA COMBINADA.
 *
 * Es un modelo VIRTUAL
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AtletasPruebasResultadosDetalleModel.php 195 2014-06-23 19:54:42Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:54:42 -0500 (lun, 23 jun 2014) $
 * $Rev: 195 $
 */
class AtletasPruebasResultadosDetalleModel extends \app\common\model\TSLAppCommonBaseModel {

    use AtletasResultadosModelTraits;
    use CompetenciasPruebasModelTraits;

    protected $competencias_pruebas_origen_id;

    /**
     * En el caso de las combinadas cada prueba tiene una prueba principal , por ejempo
     * los 110 metros con vallas son parte de la prueba heptatlon.
     *
     * @return int el id de la prueba origen de esta prueba .     *
     */
    public function get_competencias_pruebas_origen_id() {
        return $this->competencias_pruebas_origen_id;
    }

    /**
     * Se setea el id a la pruena  principal.
     * En el caso de las combinadas cada prueba tiene una prueba principal , por ejempo
     * los 110 metros con vallas son parte de la prueba heptatlon.
     *
     * @param type $competencias_pruebas_origen_id
     */
    public function set_competencias_pruebas_origen_id($competencias_pruebas_origen_id) {
        $this->competencias_pruebas_origen_id = $competencias_pruebas_origen_id;
    }

    public function &getPKAsArray() {
        $pk['atletas_resultados_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() {
        return true;
    }

}

?>