const Brand = require('../lib/models/brands');

const addBrand = async (req, res) => {
  try {
    console.log('[addBrand] Adding brand(s):', { body: req.body });
    let results;
    if (Array.isArray(req.body)) {
      // Handle array of brands (bulk insert)
      results = await Promise.all(
        req.body.map(async (brandData) => {
          const brand = new Brand(brandData);
          return await brand.save();
        })
      );
      console.log('[addBrand] Brands created:', { count: results.length });
      return res.status(201).json({
        success: true,
        results,
        message: `Successfully created ${results.length} brands`,
      });
    } else {
      // Handle single brand
      const brand = new Brand(req.body);
      results = await brand.save();
      console.log('[addBrand] Brand created:', { id: results._id, name: results.name });
      return res.status(201).json({
        success: true,
        result: results,
        message: 'Brand created successfully',
      });
    }
  } catch (error) {
    console.error('[addBrand] Error:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};

const updateBrand = async (req, res) => {
  try {
    console.log('[updateBrand] Updating brand(s):', { body: req.body });
    let results;
    if (Array.isArray(req.body)) {
      // Handle array of updates (bulk update)
      results = await Promise.all(
        req.body.map(async (updateData) => {
          const { id, ...updateFields } = updateData;
          if (!id) {
            throw new Error('ID is required for each brand update');
          }
          const brand = await Brand.findByIdAndUpdate(
            id,
            updateFields,
            { new: true, runValidators: true }
          ).lean();
          if (!brand) {
            console.log('[updateBrand] Brand not found:', { id });
            return { id, success: false, message: 'Brand not found' };
          }
          console.log('[updateBrand] Brand updated:', { id: brand._id, name: brand.name });
          return { id, success: true, result: brand };
        })
      );
      const failedUpdates = results.filter(r => !r.success);
      if (failedUpdates.length > 0) {
        return res.status(207).json({
          success: true,
          message: 'Some updates failed',
          results,
        });
      }
      return res.status(200).json({
        success: true,
        results,
        message: `Successfully updated ${results.length} brands`,
      });
    } else {
      // Handle single brand update
      const brand = await Brand.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true, runValidators: true }
      ).lean();
      if (!brand) {
        console.log('[updateBrand] Brand not found');
        return res.status(404).json({
          success: false,
          message: 'Brand not found',
        });
      }
      console.log('[updateBrand] Brand updated:', { id: brand._id, name: brand.name });
      return res.status(200).json({
        success: true,
        result: brand,
        message: 'Brand updated successfully',
      });
    }
  } catch (error) {
    console.error('[updateBrand] Error:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};

const deleteBrand = async (req, res) => {
  try {
    console.log('[deleteBrand] Deleting brand(s):', { body: req.body });
    let results;
    if (req.body && Array.isArray(req.body.ids)) {
      // Handle array of IDs (bulk delete)
      results = await Promise.all(
        req.body.ids.map(async (id) => {
          const brand = await Brand.findByIdAndDelete(id).lean();
          if (!brand) {
            console.log('[deleteBrand] Brand not found:', { id });
            return { id, success: false, message: 'Brand not found' };
          }
          console.log('[deleteBrand] Brand deleted:', { id: brand._id, name: brand.name });
          return { id, success: true };
        })
      );
      const failedDeletes = results.filter(r => !r.success);
      if (failedDeletes.length > 0) {
        return res.status(207).json({
          success: true,
          message: 'Some deletes failed',
          results,
        });
      }
      return res.status(200).json({
        success: true,
        message: `Successfully deleted ${results.length} brands`,
      });
    } else {
      // Handle single brand delete
      const brand = await Brand.findByIdAndDelete(req.params.id).lean();
      if (!brand) {
        console.log('[deleteBrand] Brand not found');
        return res.status(404).json({
          success: false,
          message: 'Brand not found',
        });
      }
      console.log('[deleteBrand] Brand deleted:', { id: brand._id, name: brand.name });
      return res.status(200).json({
        success: true,
        message: 'Brand deleted successfully',
      });
    }
  } catch (error) {
    console.error('[deleteBrand] Error:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: error.message,
    });
  }
};

const getAllBrands = async (req, res) => {
  try {
    console.log('[getAllBrands] Received request:', {
      method: req.method,
      url: req.originalUrl,
      headers: req.headers,
      timestamp: new Date().toISOString(),
    });
    console.log('[getAllBrands] Querying database for brands...');
    const brands = await Brand.find()
      .limit(6) // Limit to 6 brands for the UI
      .lean();
    console.log('[getAllBrands] Query result:', {
      brandCount: brands.length,
      brands: brands.map(b => ({
        id: b._id,
        name: b.name,
      })),
    });
    if (!brands || brands.length === 0) {
      console.log('[getAllBrands] No brands found');
      return res.status(204).json({
        success: false,
        message: 'No brands found',
      });
    }
    console.log('[getAllBrands] Successfully fetched brands');
    return res.status(200).json({
      success: true,
      brands,
    });
  } catch (error) {
    console.error('[getAllBrands] Error occurred:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
    });
  }
};

const getBrandById = async (req, res) => {
  try {
    console.log('[getBrandById] Fetching brand:', { id: req.params.id });
    const brand = await Brand.findById(req.params.id).lean();
    if (!brand) {
      console.log('[getBrandById] Brand not found');
      return res.status(404).json({
        success: false,
        message: 'Brand not found',
      });
    }
    console.log('[getBrandById] Brand fetched:', { id: brand._id, name: brand.name });
    return res.status(200).json({
      success: true,
      brand,
    });
  } catch (error) {
    console.error('[getBrandById] Error occurred:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
    });
  }
};

// Optional: Get multiple brands by IDs (if needed)
const getBrandsByIds = async (req, res) => {
  try {
    console.log('[getBrandsByIds] Fetching brands:', { ids: req.body.ids });
    if (!req.body.ids || !Array.isArray(req.body.ids)) {
      return res.status(400).json({
        success: false,
        message: 'An array of IDs is required',
      });
    }
    const brands = await Brand.find({ _id: { $in: req.body.ids } }).lean();
    console.log('[getBrandsByIds] Brands fetched:', {
      brandCount: brands.length,
      brands: brands.map(b => ({ id: b._id, name: b.name })),
    });
    if (!brands || brands.length === 0) {
      console.log('[getBrandsByIds] No brands found');
      return res.status(204).json({
        success: false,
        message: 'No brands found',
      });
    }
    return res.status(200).json({
      success: true,
      brands,
    });
  } catch (error) {
    console.error('[getBrandsByIds] Error occurred:', {
      errorName: error.name,
      errorMessage: error.message,
      errorStack: error.stack,
      timestamp: new Date().toISOString(),
    });
    return res.status(500).json({
      success: false,
      message: 'Internal Server Error',
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
    });
  }
};

module.exports = {
  addBrand,
  updateBrand,
  deleteBrand,
  getAllBrands,
  getBrandById,
  getBrandsByIds,
};