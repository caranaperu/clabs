<?php

namespace app\common\model;

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  base para todos los modelos del sistema, basicamente
 * incoirpora los campos de activo,usuario,usuario que modifica , fechas
 * relativas a la crecion y modificacion , asi como el manejo
 * de quien es pk o codigo unico del registro.
 *
 * Por ejemplo Tipos de documentos, tipos de vias, etc.
 * IMPORTANTE: no usar set id o get id directamente ya que es el codigo
 * de la entidad la que sera usada como id.
 * Todas las tablas del sistema tendran el campo activo.
 *
 * @author $Author: aranape $
 * @version $Id: TSLAppCommonBaseModel.php 4 2014-02-11 03:31:42Z aranape $
 * @history , se retiraron los campos codigo,descripcion y solo queda activo
 *
 * $Rev: 4 $
 * $Date: 2014-02-10 22:31:42 -0500 (lun, 10 feb 2014) $
 *
 */
class TSLAppCommonBaseModel extends \TSLDataModel {

    protected $activo = TRUE;

    /**
     * Si se desea que un modelo este inactivo pero no eliminado
     * este campos era util para eso.
     *
     * @param boolean $activo , 1 o true , 0 o false
     */
    public function setActivo($activo) {
        if ($activo !== 1 && $activo !== TRUE && strtoupper($activo) !== 'TRUE' && strtoupper($activo) != 'T') {
            $this->activo = FALSE;
        } else {
            $this->activo = TRUE;
        }
    }

    /**
     * Retorna TRUE si esta activo.
     *
     * @return boolean TRUE verdadero FALSE falso
     */
    public function getActivo() {
        return $this->activo;
    }
}

?>
